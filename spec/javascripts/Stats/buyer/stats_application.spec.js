import { StatsApplicationSourceCollector } from 'Stats/buyer/stats_application'
import { StatsApplicationMetricsSource } from 'Stats/lib/application_metrics_source'

const metrics = [{ systemName: 'metric-0' }, { systemName: 'metric-1' }, { systemName: 'metric-2' }]

describe('StatsApplicationSourceCollector', () => {
  it('should get the source', () => {
    expect(StatsApplicationSourceCollector.Source).toEqual(StatsApplicationMetricsSource)
  })

  it('should get sources', async () => {
    const collector = new StatsApplicationSourceCollector({
      id: 0,
      metrics: Promise.resolve({
        metrics,
        methods: []
      })
    })
    const sources = await collector.getSources({ selectedApplicationId: 0, selectedMetricName: 'metric-2' })
    expect(sources).toHaveLength(1)
  })
})

describe('StatsApplicationChartManager', () => {
  it.todo('todo')
})

describe('statsApplication', () => {
  it.todo('todo')
})
