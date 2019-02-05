import {StatsSourceCollector} from 'Stats/lib/source_collector'

describe('StatsSourceCollector', () => {
  let options = {
    dateRange: {
      since: '2015-12-29T13:00:00+00:00',
      until: '2015-12-30T13:00:00+00:00',
      granularity: 'hour'
    },
    selectedMetricName: 'hits'
  }

  let sourceCollector = new StatsSourceCollector({id: 42, metrics: []})

  beforeEach((done) => {
    spyOn(sourceCollector, '_fetchMetrics').and.callFake(() => {
      return Promise.resolve({ metrics: [
        { id: 1, systemName: 'awesome_metric' },
        { id: 2, systemName: 'amazing_metric' }
      ]})
    })
    done()
  })

  it('should throw error on url getter', () => {
    expect(() => {
      sourceCollector.url
    }).toThrow(new Error('It should implement url getter in subclasses.'))
  })

  it('should return the right params', () => {
    let params = sourceCollector.params(options)
    let expectedParams = {
      metric_name: 'hits',
      granularity: 'hour',
      since: '2015-12-29T13:00:00+00:00',
      until: '2015-12-30T13:00:00+00:00',
      skip_change: true
    }

    expect(params).toEqual(expectedParams)
  })

  it('should get the correct sources', (done) => {
    spyOn(sourceCollector, 'buildSources')
    sourceCollector.getMetrics('/le/cool/url')
    sourceCollector.getSources({id: 42, selectedMetricName: 'awesome_metric'}).then(_res => {
      expect(sourceCollector.buildSources).toHaveBeenCalledWith(42, [{id: 1, systemName: 'awesome_metric'}])
      done()
    })
  })

  it('should build the right sources', () => {
    class StubbedSource {
      constructor ({id, details}) {
        this.id = id
        this.details = details
      }
    }

    class ChildSourceCollector extends StatsSourceCollector {
      static get Source () {
        return StubbedSource
      }
    }

    let selectedMetrics = [{id: 7, systemName: 'bond'}]

    let childSourceCollector = new ChildSourceCollector({id: 42, metrics: {}})
    let sources = childSourceCollector.buildSources(42, selectedMetrics)

    expect(sources[0] instanceof StubbedSource).toBe(true)
    expect(JSON.stringify(sources))
      .toEqual('[{"id":42,"details":{"id":7,"systemName":"bond"}}]')
  })
})
