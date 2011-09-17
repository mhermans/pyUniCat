import sys
sys.path.append('../')
from api import Query

def test_cql_construction():
    p = Query('lifecourse')
    q = Query()
    q.cqlp['term'] = 'lifecourse'
    assert p.cql == q.cql ==  'srw.ServerChoice = "lifecourse"'

    p.cqlp['year'] = 1990
    q.cqlp['year'] = '1990'
    assert p.cql == q.cql == 'srw.ServerChoice = "lifecourse" and year = 1990'
