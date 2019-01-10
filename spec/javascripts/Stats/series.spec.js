import {StatsSeries} from 'Stats/lib/series'

describe('StatsSeries', () => {
  let source = {
    data: () => {}
  }

  beforeEach((done) => {
    spyOn(source, 'data').and.callFake(() => {
      return new Promise((resolve) => {
        resolve({
          metric: {
            id: 7,
            name: 'Bond, James Bond',
            system_name: 'james_bond',
            unit: 'spies'
          },
          period: {
            granularity: 'day',
            since: '2006-11-17T00:00:00-07:00',
            until: '2006-11-18T23:59:59-07:00',
            timezone: 'America/Los_Angeles'
          },
          total: 42,
          values: [42]
        })
      })
    })
    done()
  })

  it('should get the correct data', (done) => {
    let stateOptions = {}
    let statsSerie = new StatsSeries([source])

    statsSerie.getData(stateOptions).then(response => {
      expect(JSON.stringify(response)).toBe(
        JSON.stringify({
          columns: [ [ 'x', '2006-11-16T23:00:00', '2006-11-17T23:00:00' ], [ 'Bond, James Bond', 42 ] ],
          unload: true,
          _period: {
            granularity: 'day',
            since: '2006-11-17T00:00:00-07:00',
            until: '2006-11-18T23:59:59-07:00',
            timezone: 'America/Los_Angeles'
          },
          _totalValues: 42
        })
      )
      done()
    })
  })
})
