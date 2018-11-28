import $ from 'jquery'

import {StatsTopAppsSourceCollector} from 'Stats/lib/top_apps_source_collector'

describe('StatsTopAppsSourceCollector', () => {
  let options = {
    dateRange: {
      since: '2016-11-25T13:00:00+00:00',
      until: '2016-12-01T13:00:00+00:00',
      granularity: 'day'
    },
    selectedMetricName: 'marvin'
  }

  let metrics = Promise.resolve({
    metrics: [{id: 7, name: 'Marvin', systemName: 'marvin'}]
  })

  let sourceCollector = new StatsTopAppsSourceCollector({id: 42, metrics})

  it('should return the right params', () => {
    let params = sourceCollector.params(options)
    let expectedParams = {
      metric_name: 'marvin',
      granularity: 'day',
      since: '2016-11-25T13:00:00+00:00',
      until: '2016-12-01T13:00:00+00:00',
      skip_change: true,
      period: 'week'
    }

    expect(params).toEqual(expectedParams)
  })

  it('should provide the correct url', () => {
    expect(sourceCollector.url).toEqual('/stats/services/42/top_applications.json')
  })

  it('should get the right sources', (done) => {
    spyOn($, 'getJSON').and.callFake(() => {
      let deferred = new $.Deferred()
      deferred.resolve({
        period: {since: '2016-11-21T00:00:00-00:00', until: '2016-11-27T23:59:59-00:00', name: 'week'},
        applications: [{id: 42}]
      })
      return deferred.promise()
    })

    sourceCollector.getSources(options).then((sources) => {
      expect(JSON.stringify(sources)).toBe(
        '[{"details":{"id":7,"name":"Marvin","systemName":"marvin"},"id":42,"topAppsSelectionPeriod":{"since":"2016-11-21T00:00:00-00:00","until":"2016-11-27T23:59:59-00:00","name":"week"}}]'
      )
      done()
    })
  })
})
