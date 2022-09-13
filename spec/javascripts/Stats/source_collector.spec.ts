import { StatsSourceCollector } from 'Stats/lib/source_collector'

describe('StatsSourceCollector', () => {
  const options = {
    dateRange: {
      since: '2015-12-29T13:00:00+00:00',
      until: '2015-12-30T13:00:00+00:00',
      granularity: 'hour'
    },
    selectedMetricName: 'hits'
  }

  const sourceCollector = new StatsSourceCollector({ id: 42, metrics: [] })

  beforeEach((done) => {
    jest.spyOn(sourceCollector, '_fetchMetrics')
      .mockResolvedValue({
        metrics: [
        { id: 1, systemName: 'awesome_metric' },
        { id: 2, systemName: 'amazing_metric' }
        ]
      })
    done()
  })

  it('should throw error on url getter', () => {
    expect(() => {
      sourceCollector.url // eslint-disable-line no-unused-expressions
    }).toThrow(new Error('It should implement url getter in subclasses.'))
  })

  it('should return the right params', () => {
    const params = sourceCollector.params(options)
    const expectedParams = {
      metric_name: 'hits',
      granularity: 'hour',
      since: '2015-12-29T13:00:00+00:00',
      until: '2015-12-30T13:00:00+00:00',
      skip_change: true
    }

    expect(params).toEqual(expectedParams)
  })

  // Todo: update  this test
  it.skip('should get the correct sources', (done) => {
    const buildSourcesSpy = jest.spyOn(sourceCollector, 'buildSources')
    sourceCollector.getMetrics('/le/cool/url')
    sourceCollector.getSources({ id: 42, selectedMetricName: 'awesome_metric' }).then(_res => {
      expect(buildSourcesSpy).toHaveBeenCalledWith(42, [{ id: 1, systemName: 'awesome_metric' }])
      done()
    })
  })

  it('should build the right sources', () => {
    class StubbedSource {
      constructor ({ id, details }) {
        this.id = id
        this.details = details
      }
    }

    class ChildSourceCollector extends StatsSourceCollector {
      static get Source () {
        return StubbedSource
      }
    }

    const selectedMetrics = [{ id: 7, systemName: 'bond' }]

    const childSourceCollector = new ChildSourceCollector({ id: 42, metrics: {} })
    const sources = childSourceCollector.buildSources(42, selectedMetrics)

    expect(sources[0] instanceof StubbedSource).toBe(true)
    expect(JSON.stringify(sources))
      .toEqual('[{"id":42,"details":{"id":7,"systemName":"bond"}}]')
  })
})
