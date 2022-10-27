import { StatsApplicationMetricsSource } from 'Stats/lib/application_metrics_source'

class TestStatsApplicationMetricsSource extends StatsApplicationMetricsSource {}

it('should return an URL', () => {
  const source = new TestStatsApplicationMetricsSource({ id: 123 })
  expect(source.url).toEqual('/stats/api/applications/123/usage.json')
})
