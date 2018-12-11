import {StatsSourceCollector} from 'Stats/lib/source_collector'
import {StatsUsageMetricsSource} from 'Stats/lib/usage_metrics_source'

export class StatsUsageSourceCollector extends StatsSourceCollector {
  static get Source () {
    return StatsUsageMetricsSource
  }
}
