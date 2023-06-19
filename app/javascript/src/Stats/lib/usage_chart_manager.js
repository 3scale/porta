import { StatsSourceCollectorChartManager } from 'Stats/lib/source_collector_chart_manager'
import { StatsUsageSeries } from 'Stats/lib/usage_series'

export class StatsUsageChartManager extends StatsSourceCollectorChartManager {
  static get Series () {
    return StatsUsageSeries
  }
}
