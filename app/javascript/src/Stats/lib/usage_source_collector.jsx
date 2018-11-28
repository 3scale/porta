import {StatsSourceCollector} from './source_collector'
import {StatsUsageMetricsSource} from './usage_metrics_source'

export class StatsUsageSourceCollector extends StatsSourceCollector {
  static get Source () {
    return StatsUsageMetricsSource
  }
}
