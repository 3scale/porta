import {StatsMetrics} from 'stats/lib/metrics_list'

describe('StatsMetrics', () => {
  beforeEach((done) => {
    spyOn(StatsMetrics, '_makeRequest').and.callFake(() => {
      return Promise.resolve({metrics: [
          { metric: {id: 1, service_id: 1, friendly_name: 'Awesome Metric', system_name: 'awesome_metric'} },
          { metric: {id: 2, service_id: 1, firendly_name: 'Amazing Metric', system_name: 'amazing_metric'} }
      ]})
    })
    done()
  })

  it('should get the correct list of metrics', (done) => {
    StatsMetrics.getMetrics('/cool/url/').then(metrics => {
      expect(JSON.stringify(metrics)).toEqual(
        '{"metrics":[{"id":1,"name":"Awesome Metric","serviceId":1,"systemName":"awesome_metric","isMethod":false},{"id":2,"serviceId":1,"systemName":"amazing_metric","isMethod":false}]}'
      )
      done()
    })
  })

  it('should get the selected metrics', () => {
    let list = {metrics: [
      {id: 1, serviceId: 1, name: 'Awesome Metric', systemName: 'awesome_metric', isMethod: false},
      {id: 2, serviceId: 1, name: 'Amazing Metric', systemName: 'amazing_metric', isMethod: false}
    ]}
    let selectedMetrics = StatsMetrics.getSelectedMetrics({selectedMetricName: 'amazing_metric', list})
    expect(JSON.stringify(selectedMetrics)).toEqual('[{"id":2,"serviceId":1,"name":"Amazing Metric","systemName":"amazing_metric","isMethod":false}]')
  })
})
