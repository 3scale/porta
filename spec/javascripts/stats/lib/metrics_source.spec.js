import $ from 'jquery'

import {StatsMetricsSource} from 'stats/lib/metrics_source'

let source = new StatsMetricsSource({id: 42, details: {id: 8, system_name: 'slartibarfast'}})

describe('StatsMetricsSource', () => {
  let options = {
    dateRange: {
      since: '1952-03-11T00:00:00',
      until: '2001-05-11T23:59:59',
      granularity: 'hour'
    },
    selectedMetricName: 'zaphod'
  }

  it('should return the right params', () => {
    let params = source.params(options)
    let expectedParams = {
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
      source.url
    }).toThrow(new Error('It should implement url getter in subclasses.'))
  })
})

describe('CustomMetricSource', () => {
  let options = {
    dateRange: {
      since: '1952-03-11T00:00:00',
      until: '2001-05-11T23:59:59',
      granularity: 'hour'
    },
    timezone: 'Asia/Kamchatka',
    selectedMetricName: 'zaphod'
  }

  class CustomMetricSource extends StatsMetricsSource {
    get url () { return 'http://example.com/api' }
  }

  beforeEach((done) => {
    spyOn($, 'getJSON').and.callFake(() => {
      return new $.Deferred()
    })
    done()
  })

  it('should make an ajax request with the right params', (done) => {
    let source = new CustomMetricSource({id: 42, details: {id: 7, system_name: 'marvin'}})
    source.data(options)

    expect($.getJSON).toHaveBeenCalledWith('http://example.com/api', {
      metric_name: 'zaphod',
      granularity: 'hour',
      since: '1952-03-11T00:00:00',
      until: '2001-05-11T23:59:59',
      timezone: 'Asia/Kamchatka',
      skip_change: true
    })
    done()
  })
})
