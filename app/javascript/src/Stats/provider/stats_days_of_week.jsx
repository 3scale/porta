/** @jsx StatsUI.dom */

import {PeriodRangeDate} from 'Stats/lib/state'
import {StatsAverageMetricsSource} from 'Stats/lib/average_metrics_source'
import {StatsChart} from 'Stats/lib/chart'
import {StatsAverageChartManager} from 'Stats/lib/average_chart_manager'
import {StatsMetrics} from 'Stats/lib/metrics_list'
import {StatsCSVLink} from 'Stats/lib/csv_link'
import {Stats} from 'Stats/lib/stats'

import numeral from 'numeral'

const PERIOD = { number: 30, unit: 'day' }

class StatsDaysOfWeekChart extends StatsChart {
  _chartCustomOptions () {
    return {
      axis: {
        x: {
          type: 'category',
          categories: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        },
        y: {
          tick: {
            format: d => numeral(d).format('0.0a').toUpperCase()
          }
        }
      },
      data: {
        colors: {
          'Hits': '#4A90E2'
        },
        type: 'spline',
        columns: []
      }
    }
  }
}

class StatsDaysOfWeekCsvLink extends StatsCSVLink {
  _parseTimeColumn (columns) {
    columns.unshift(['Day of the week', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'])
    return columns
  }
}

let statsDaysOfWeek = (serviceId, options = {}) => {
  let selectedState = { dateRange: new PeriodRangeDate(PERIOD) }
  let usageMetricsUrl = `/services/${serviceId}/stats/usage.json`
  let metrics = StatsMetrics.getMetrics(usageMetricsUrl)
  let csvLink = new StatsDaysOfWeekCsvLink({container: options.csvLinkContainer})

  Stats({ChartManager: StatsAverageChartManager, Chart: StatsDaysOfWeekChart, Sources: StatsAverageMetricsSource}).build({
    id: serviceId,
    selectedState,
    metrics,
    widgets: [csvLink],
    options: {
      hasMenu: false,
      hasGroupedMethods: false,
      isSourceCollector: false
    }
  })
}

export { statsDaysOfWeek }
