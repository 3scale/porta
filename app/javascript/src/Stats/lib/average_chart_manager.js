import { StatsAverageSeries } from 'Stats/lib/average_series'
import { StatsChartManager } from 'Stats/lib/chart_manager'

export class StatsAverageChartManager extends StatsChartManager {
  static get Series () {
    return StatsAverageSeries
  }
}
