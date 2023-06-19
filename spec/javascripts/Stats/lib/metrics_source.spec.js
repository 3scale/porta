/* eslint-disable @typescript-eslint/explicit-member-accessibility */
/* eslint-disable @typescript-eslint/no-unnecessary-condition */
/* eslint-disable @typescript-eslint/no-invalid-this */
import $ from 'jquery'

import { StatsMetricsSource } from 'Stats/lib/metrics_source'

const source = new StatsMetricsSource({ id: 42, details: { id: 8, system_name: 'slartibarfast' } })

describe('StatsMetricsSource', () => {
  const options = {
    dateRange: {
      since: '1952-03-11T00:00:00',
      until: '2001-05-11T23:59:59',
      granularity: 'hour'
    },
    selectedMetricName: 'zaphod'
  }

  it('should return the right params', () => {
    const params = source.params(options)
    const expectedParams = {
      metric_name: 'zaphod',
      granularity: 'hour',
      since: '1952-03-11T00:00:00',
      until: '2001-05-11T23:59:59',
      timezone: undefined, // It's OK to be undefined, then it won't be added to the ajax call if not passed.
      skip_change: true
    }

    expect(params).toEqual(expectedParams)
  })

  it('should throw error when call url directly', () => {
    expect(() => {
      // eslint-disable-next-line @typescript-eslint/no-unused-expressions
      source.url
    }).toThrow(new Error('It should implement url getter in subclasses.'))
  })
})

// Todo: Implementation depends a lot on jQuery, testing without jQuery may require a refactor
describe('CustomMetricSource', () => {
  const options = {
    dateRange: {
      since: '1952-03-11T00:00:00',
      until: '2001-05-11T23:59:59',
      granularity: 'hour'
    },
    timezone: 'Asia/Kamchatka',
    selectedMetricName: 'zaphod'
  }

  class CustomMetricSource extends StatsMetricsSource {
    constructor ({ id, details }) {
      super({ id, details })
    }

    // eslint-disable-next-line @typescript-eslint/class-literal-property-style
    get url () { return 'http://example.com/api' }
  }

  beforeEach(() => {
    jest.spyOn($, 'getJSON')
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
      .mockReturnValue({
        getJSON: () => { return this },
        done: (fn) => {
          if (fn) fn()
          return this
        },
        fail: (fn) => {
          if (fn) fn()
          return this
        }
      })
  })

  it('should make an ajax request with the right params', async () => {
    const source = new CustomMetricSource({ id: 42, details: { id: 7, system_name: 'marvin' } })
    await source.data(options)

    expect($.getJSON).toHaveBeenCalledWith('http://example.com/api', {
      metric_name: 'zaphod',
      granularity: 'hour',
      since: '1952-03-11T00:00:00',
      until: '2001-05-11T23:59:59',
      timezone: 'Asia/Kamchatka',
      skip_change: true
    })
  })
})
