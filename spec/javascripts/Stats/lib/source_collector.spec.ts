/* eslint-disable @typescript-eslint/no-unsafe-return */
/* eslint-disable @typescript-eslint/explicit-function-return-type */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/lines-between-class-members */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-floating-promises */
/* eslint-disable @typescript-eslint/naming-convention */
/* eslint-disable @typescript-eslint/explicit-member-accessibility */
/* eslint-disable @typescript-eslint/no-unused-expressions */
import { StatsSourceCollector } from 'Stats/lib/source_collector'

class TestStatsSourceCollector extends StatsSourceCollector {
  constructor ({ id, metrics }: { id: number; metrics: [] }) {
    super({ id, metrics })
  }
}

describe('StatsSourceCollector', () => {
  const options = {
    dateRange: {
      since: '2015-12-29T13:00:00+00:00',
      until: '2015-12-30T13:00:00+00:00',
      granularity: 'hour'
    },
    selectedMetricName: 'hits'
  }

  const sourceCollector = new TestStatsSourceCollector({ id: 42, metrics: [] })

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
      sourceCollector.url
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
    sourceCollector.getSources({ id: undefined, selectedMetricName: 'awesome_metric' }).then(() => {
      expect(buildSourcesSpy).toHaveBeenCalledWith(42, [{ id: 1, systemName: 'awesome_metric' }])
      done()
    })
  })

  it('should build the right sources', () => {
    class StubbedSource {
      id: number
      details: any

      constructor ({ id, details }: { id: number; details: any }) {
        this.id = id
        this.details = details
      }
    }

    class ChildSourceCollector extends TestStatsSourceCollector {
      static get Source () {
        return StubbedSource as any
      }
    }

    const selectedMetrics = [{ id: 7, systemName: 'bond' }]

    const childSourceCollector = new ChildSourceCollector({ id: 42, metrics: [] })
    const sources = childSourceCollector.buildSources(42, selectedMetrics)

    expect(sources[0] instanceof StubbedSource).toBe(true)
    expect(JSON.stringify(sources))
      .toEqual('[{"id":42,"details":{"id":7,"systemName":"bond"}}]')
  })
})
