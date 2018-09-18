import {StatsChartManager} from './chart_manager'
import {StatsAverageSeries} from './average_series'

export class StatsAverageChartManager extends StatsChartManager {
  static get Series () {
    return StatsAverageSeries
  }
}
