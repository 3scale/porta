/** @jsx StatsUI.dom */

import { PeriodRangeDate } from 'Stats/lib/state'
import { StatsAverageMetricsSource } from 'Stats/lib/average_metrics_source'
import { StatsChart } from 'Stats/lib/chart'
import { StatsAverageChartManager } from 'Stats/lib/average_chart_manager'
import { StatsMetrics } from 'Stats/lib/metrics_list'
import { StatsCSVLink } from 'Stats/lib/csv_link'
import { Stats } from 'Stats/lib/stats'

import numeral from 'numeral'

const PERIOD = { number: 30, unit: 'day', granularity: 'hour' }

class StatsHoursOfDayChart extends StatsChart {
  _chartCustomOptions () {
    return {
      axis: {
        x: {
          type: 'category',
          categories: ['12am', '1am', '2am', '3am', '4am', '5am', '6am', '7am', '8am', '9am', '10am', '11am',
            '12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '6pm', '7pm', '8pm', '9pm', '10pm', '11pm']
        },
        y: {
          tick: {
            format: d => {
              const format = d < 1000 ? '0' : '0.0a'
              return numeral(d).format(format).toUpperCase()
            }
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

class StatsHoursOfDayCsvLink extends StatsCSVLink {
  _parseTimeColumn (columns) {
    columns.unshift(['Hours of the day', '12am', '1am', '2am', '3am', '4am', '5am', '6am', '7am', '8am', '9am', '10am', '11am',
      '12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '6pm', '7pm', '8pm', '9pm', '10pm', '11pm'])
    return columns
  }
}

let statsHoursOfDay = (serviceId, options = {}) => {
  let selectedState = { dateRange: new PeriodRangeDate(PERIOD) }
  let usageMetricsUrl = `/services/${serviceId}/stats/usage.json`
  let metrics = StatsMetrics.getMetrics(usageMetricsUrl)
  let csvLink = new StatsHoursOfDayCsvLink({ container: options.csvLinkContainer })

  Stats({ ChartManager: StatsAverageChartManager, Chart: StatsHoursOfDayChart, Sources: StatsAverageMetricsSource }).build({
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

export { statsHoursOfDay }
