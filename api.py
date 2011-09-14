#! /usr/bin/env python

import sys, os
from pprint import pprint
import requests
from tablib import Dataset
from lxml import objectify, etree
try:
    from collections import Counter
except ImportError: # <2.7
    from patch import Counter

import logging
log = logging.getLogger('unicat')
#log.setLevel(logging.DEBUG)
log.setLevel(logging.INFO)
console = logging.StreamHandler()
log.addHandler(console)
#flog = logging.FileHandler('scraper.log')
#log.addHandler(flog)

class Query(object):
    def __init__(self, term=None, datadir='data'):
        if term: self.term = term
        self.datadir = datadir
        self.filename = '.'.join([self.term.replace(' ', '_'), 'xml'])
        self.filename = os.path.join(os.path.abspath(self.datadir), self.filename)

    def get_records(self):
        #filename = '.'.join([self.term.replace(' ', '_'), 'xml'])
        if os.path.exists(self.filename):
            log.info('"%s": Found file %s' % (self.term, self.filename))
            f = open(self.filename)
            xml = f.read()
            f.close()
            log.info('"%s": Records from file' % self.term)
            r = ResultSet(xml)
            r.filename = self.filename
            return r

        else:
            log.info('"%s": Records from SRW' % self.term)
            r = self.execute(collate=True)
            r.filename = self.filename
            return r

    def execute(self, offset=1, collate=False):
        log.info('"%s": executing SRW query' % self.term)
        r = requests.get('http://www.unicat.be/sru?version=1.1&operation=searchRetrieve&query=%s&recordSchema=dc&startRecord=%s' % (self.term, offset) )
        #r.status_code
        #r.headers

        if not collate:
            return ResultSet(r.content)
        else:
            first_recordSet = self.execute(offset=1, collate=False)
            total_records =  first_recordSet.reported_count

            if total_records < 21:
                offsets = [11]
            else:
                offsets = range(11, total_records, 10) #XXX mist laaste 10 records?

            for offset in offsets:
                log.info('"%s": Collating records %s-%s' % (self.term, offset, offset+10) )
                print '\t', 'process', offset
                result = self.execute(offset=offset, collate=False)
                for record in result.records:
                    #first_result.records.append(record)
                    first_recordSet.root.xpath('srw:records', namespaces=first_recordSet.ns)[0].append(record)
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

        #self.term = self.root.xpath('//xcql:term[0]/text()', namespaces=self.ns)
        self.term = self.root.xpath('//xcql:term/text()', namespaces=self.ns)[0]


    @property
    def reported_count(self):
        #return int(self.obj_tree.numberOfRecords)
        return int(self.root.xpath('srw:numberOfRecords/text()', namespaces=self.ns)[0])

    @property
    def true_count(self):
        #return int(self.obj_tree.records.countchildren())
        return len(self.root.xpath('//srw:record', namespaces=self.ns))

    @property
    def records(self):
        return self.root.xpath('//srw:record', namespaces=self.ns)

    def dates(self, mindate=None, maxdate=None):
        dates = [int(date) for date in self.root.xpath('//dc:date/text()', namespaces=self.ns) if date.isdigit()]
        c = Counter(dates)
        full_range = {}
        if not mindate: mindate = min(dates)
        if not maxdate: maxdate = max(dates)
        for date in range(mindate, maxdate):
            full_range[date] = c.get(date, 0)
        return full_range

    #def get_data(term, datadir='data'):
    #    filename = '.'.join([term.replace(' ', '_'), 'xml'])
    #    filename = os.path.exists(os.path.join(os.path.abspath(datadir), filename))
    #    if not filename: 
    #        store_data(term, filename)
    #
    #    print get_dates(filename, 1900, 2011).values()

    def save(self, filename=None):
        if not filename: filename = self.filename
        #if not filename:
        #    filename = '.'.join([self.term.replace(' ', '_'), 'xml'])
        #    filename = os.path.join(os.path.abspath(self.datadir), filename)

        #r = self.get_records() 
        #f = open(self.filename, 'w')
        #f.write(self.root.tostring(encoding='utf-8'))
        self.root.getroottree().write(filename, encoding='utf-8')
        #f.close()
        log.info('Written XML to %s' % filename)
        #self.root.write(filename, encoding='utf-8')

    #main()
    #xml = process('stratificatie.xml')
    #print count('minderheden')
    #ns = {'srw' : xml.nsmap.values()[0]}
    #r = xml.xpath('//srw:record', namespaces=ns)[0]
    #print get_dates('stratificatie.xml', 1900, 2011)
    #get_data("sociale klasse")

def export(terms, filename):

    data = Dataset()
    data.headers = ['why?']
    data.insert_col(0, range(1900,2011), header='year')
    for term in terms:
        q = Query(term)
        r = q.get_records()
        if not os.path.exists(r.filename): r.save()
        #print r.term
        data.append_col(r.dates(1900,2011).values(), header=r.term)
    data.headers.remove('why?')

    f = open(filename, 'w')
    f.write(data.csv)
    f.close()

    return data

def main():
    allo_words = ['minderheden', 'multiculturaliteit', 'multicultureel',
        'integratie', 'migranten', 'intercultureel', 'vreemdelingen', 'migratie',
        'immigratie', 'allochtonen', 'Marokkaanse', 'Turkse']
    prog_words = ['socialisme', 'marxisme', 'imperialisme', 'revolutie',
        'feminisme', 'anarchisme', 'revolutionair']

    auth_words = ['marx', 'bourdieu', 'giddens', 'foucault', 'weber', 'habermas',
        'chomsky', 'simmel', 'rawls', 'keynes', 'braudel']

    ineq_words = ['emancipatie', 'ongelijkheid', 'gelijkheid', 'armen',
        'armoede', 'stratificatie', 'deprivatie']

    export(allo_words, 'allo.csv')
    export(prog_words, 'prog.csv')
    export(auth_words, 'auth.csv')
    export(ineq_words, 'ineq.csv')

if __name__ == '__main__':
    main()
