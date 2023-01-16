import { StatsApplicationSourceCollector } from 'Stats/buyer/stats_application'
import { StatsApplicationMetricsSource } from 'Stats/lib/application_metrics_source'

describe('StatsApplicationSourceCollector', () => {
  it('should get the source', () => {
    expect(StatsApplicationSourceCollector.Source).toEqual(StatsApplicationMetricsSource)
  })

  it('should get sources', () => {
    const sources = new StatsApplicationSourceCollector({ id: 0, metrics: Promise.resolve([]) }).getSources({ selectedApplicationId: 0, selectedMetricName: '' })
    expect(sources).not.toBeUndefined()
  })
})

describe('StatsApplicationChartManager', () => {
  it.todo('todo')
})

describe('statsApplication', () => {
  it.todo('todo')
})
