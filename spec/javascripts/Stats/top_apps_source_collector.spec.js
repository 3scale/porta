import { StatsTopAppsSourceCollector } from 'Stats/lib/top_apps_source_collector'

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
    metrics: [{ id: 7, name: 'Marvin', systemName: 'marvin' }]
  })

  let sourceCollector = new StatsTopAppsSourceCollector({ id: 42, metrics })

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
    expect(sourceCollector.url).toEqual('/stats/api/services/42/top_applications.json')
  })

  it.todo('should get the right sources')
})
