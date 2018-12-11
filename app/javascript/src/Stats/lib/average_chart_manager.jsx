import {StatsChartManager} from 'Stats/lib/chart_manager'
import {StatsAverageSeries} from 'Stats/lib/average_series'

export class StatsAverageChartManager extends StatsChartManager {
  static get Series () {
    return StatsAverageSeries
  }
}
