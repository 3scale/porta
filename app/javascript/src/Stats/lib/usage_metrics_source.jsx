import {StatsMetricsSource} from 'Stats/lib/metrics_source'

export class StatsUsageMetricsSource extends StatsMetricsSource {
  get url () {
    return `/stats/api/services/${this.id}/usage.json`
  }
}
