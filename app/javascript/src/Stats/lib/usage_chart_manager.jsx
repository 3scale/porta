import {StatsUsageSeries} from './usage_series'
import {StatsSourceCollectorChartManager} from './source_collector_chart_manager'

export class StatsUsageChartManager extends StatsSourceCollectorChartManager {
  static get Series () {
    return StatsUsageSeries
  }
}
