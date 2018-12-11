import {StatsMetricsSource} from 'Stats/lib/metrics_source'

export class StatsUsageMetricsSource extends StatsMetricsSource {
  get url () {
    return `/stats/services/${this.id}/usage.json`
  }
}
