import {StatsMetricsSource} from 'Stats/lib/metrics_source'

export class StatsUsageBackendApiMetricsSource extends StatsMetricsSource {
  get url () {
    return `/stats/backend_apis/${this.id}/usage.json`
  }
}
