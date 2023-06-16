import { StatsSourceCollector } from 'Stats/lib/source_collector'
import { StatsUsageBackendApiMetricsSource } from 'Stats/lib/usage_backend_api_metrics_source'

export class StatsUsageBackendApiSourceCollector extends StatsSourceCollector {
  static get Source () {
    return StatsUsageBackendApiMetricsSource
  }
}
