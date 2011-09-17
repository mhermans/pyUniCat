#! /usr/bin/env python

import sys, os, urllib, logging
import requests, redis, tablib
from lxml import etree
try:
    from collections import Counter
except ImportError: # Python <2.7
    from patch import Counter

log = logging.getLogger('unicat')
log.setLevel(logging.DEBUG)
#log.setLevel(logging.INFO)
#console = logging.StreamHandler()
#log.addHandler(console)
flog = logging.FileHandler('unicat.log')
log.addHandler(flog)

#requests.settings.verbose = sys.stdout

class Query(object):
    def __init__(self, term=None, datadir='data', cache=None):
        self.cqlp = {}
        self.cqlp['term'] = term
        self.cqlp['year'] = None
        self.cqlp['language'] = None

        self.datadir = datadir

        self.recordSchema = 'dc'
        self.baseurl = 'http://www.unicat.be/sru'
        self.version = '1.1'
        self.operation = 'searchRetrieve'
        self.maximumRecords = 100

        if cache:
            self.cache = cache 

    @property
    def filename(self):
        #XXX hash cql query as filename
        filename = '.'.join([self.query['term'].replace(' ', '_'), 'xml'])
        filename = os.path.join(os.path.abspath(self.datadir), filename)
        return filename

    @property
    def cql(self):

        cqlstring = []
        if self.cqlp['term']: 
            cqlstring.extend([''.join(['srw.ServerChoice = \"',
                self.cqlp['term'], '\"'])])
        if self.cqlp['year']: 
            cqlstring.extend([''.join(['year = ', str(self.cqlp['year'])])])
        if self.cqlp['language']: 
            cqlstring.extend([''.join(['language = ', self.cqlp['language']])])

        return ' and '.join(cqlstring)

    def fetch(self, url, cached=True):
        log.info('Fetcing url: %s' % url)
        xml_body = self.cache.get(url)

        if xml_body:
            log.info('Fetching XML from cache')
            return xml_body

        else:
            log.info('Fetching XML from web')
            r = requests.get(url)
            log.info(r.content)
            #r.status_code #XXX error handling
            #r.headers

            self.cache.set(url, r.content)
            return r.content

    def execute(self, offset=1, collate=False):
        log.info('"%s": executing SRW query' % self.cqlp['term'])

        params = {  'query' : self.cql,
                    'version' : self.version,
                    'operation' : self.operation,
                    'startRecord' : offset,
                    'maximumRecords' : self.maximumRecords,
                    'recordSchema' : self.recordSchema }

        #r = requests.request('GET', url=self.baseurl, params=params)
        url = self.baseurl + '?' + urllib.urlencode(params) 
        xml_body = self.fetch(url)

        if not collate:
            return ResultSet(xml_body)
        else:
            first_recordSet = self.execute(offset=1, collate=False)
            total_records =  first_recordSet.reported_count

            if total_records < 21: #TODO fix for variable maxNrRecords
                offsets = [11]
            else:
                #XXX mist laaste 10 records?
                offsets = range(11, total_records, 10) 

            for offset in offsets:
                log.info('"%s": Collating records %s-%s' % 
                    (self.term, offset, offset+10) )
                print '\t', 'process', offset
                result = self.execute(offset=offset, collate=False)
                for record in result.records:
                    #first_result.records.append(record)
                    first_recordSet.root.xpath('srw:records', 
                        namespaces=first_recordSet.ns)[0].append(record)
                    #print record

            #r = ResultSet(first_result)
            r = first_recordSet
            r.filename = self.filename

            return r

class ResultSet(object):

    def __init__(self, xmlinput):
        if os.path.exists(xmlinput):
            self.root = etree.parse(xmlinput)
            self.xml = etree.trostring()
        else:
            self.root = etree.fromstring(xmlinput)
            self.xml = xmlinput

        self.ns = { 'dc' : 'http://purl.org/dc/elements/1.1/',
                    'srw': 'http://www.loc.gov/zing/srw/',
                    'xcql': 'http://www.loc.gov/zing/cql/xcql/'}
        try:
            self.term = self.root.xpath('//xcql:term/text()', 
                namespaces=self.ns)[0]
        except IndexError:
            self.term = ""


    @property
    def reported_count(self):
        return int(self.root.xpath('srw:numberOfRecords/text()', 
            namespaces=self.ns)[0])

    @property
    def true_count(self):
        return len(self.root.xpath('//srw:record', namespaces=self.ns))

    @property
    def records(self):
        return self.root.xpath('//srw:record', namespaces=self.ns)

    def dates(self, mindate=None, maxdate=None):
        dates = [int(date) for date in self.root.xpath('//dc:date/text()', 
            namespaces=self.ns) if date.isdigit()] # filter e.g. year = "s.d"
        c = Counter(dates)

        full_range = {}
        if not mindate: mindate = min(dates)
        if not maxdate: maxdate = max(dates)
        for date in range(mindate, maxdate):
            full_range[date] = c.get(date, 0)
        return full_range

    def save(self, filename=None):
        if not filename: filename = self.filename
        self.root.getroottree().write(filename, encoding='utf-8')
        log.info('Written XML to %s' % filename)


class UniCat(object):
    def __init__(self, cache=True):
        if cache: 
            self.cache = redis.Redis(host='localhost', port=6379, db=0)

    def get_dates(self, terms=None, start=1900, stop=2010):
        if type(terms) != list: terms = [terms]
        data = tablib.Dataset()

        for term in terms:
            results = {}
            for year in range(start,stop):
                log.info(terms)
                log.info('Fetching %s for %s' % (year, term))

                # set up query
                q = Query(cache=self.cache)
                q.cqlp['year'] = year
                if term: q.cqlp['term'] = term
                q.maximumRecords = 1
                
                # execute query and insert date-counts
                r = q.execute(collate=False)
                results[year] = r.reported_count

                if not term: # only year query->total nr. of records
                    term_label = 'total'
                else:
                    term_label = term

            data.append_col(results.values(), header=term_label)
        
        # append query results to dataset
        data.append_col(range(start, stop), header='year')

        # set headers
        terms.extend(['year'])
        data.headers = terms 

        return data

def main():
    terms = [term.strip() for term in sys.argv[1].split(',')]
    u = UniCat()
    print u.get_dates(terms).csv



if __name__ == '__main__':
    main()
