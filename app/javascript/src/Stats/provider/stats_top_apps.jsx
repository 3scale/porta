/** @jsx StatsUI.dom */
import 'core-js/fn/array/find'
import moment from 'moment'

import {StatsUI} from 'Stats/lib/ui'
import {StatsChart} from 'Stats/lib/chart'
import {StatsTopAppsSourceCollector} from 'Stats/lib/top_apps_source_collector'
import {StatsSourceCollectorChartManager} from 'Stats/lib/source_collector_chart_manager'
import {StatsSeries} from 'Stats/lib/series'
import {StatsMetrics} from 'Stats/lib/metrics_list'
import {StatsCSVLink} from 'Stats/lib/csv_link'
import {StatsApplicationsTable} from 'Stats/lib/applications_table'
import {applicationDetails} from 'Stats/lib/application_details'
import {Stats} from 'Stats/lib/stats'

export class StatsTopAppsMetrics extends StatsMetrics {
  getSelectedMetrics (selectedMetricName) {
    return this.getMetrics().then(list => {
      return [list.metrics.find(metric => metric.systemName === selectedMetricName)]
    })
  }

}

export class StatsTopAppsSeries extends StatsSeries {
  _getSeriesName (serie) {
    return `${serie.application.name} by ${serie.application.account.name}`
  }

  _totalValues (responses) {
    return responses.map((response) => response.total).reduce((previous, current) => previous + current, 0)
  }

  _customOptions (responses) {
    return {
      _topAppsSelectionPeriod: responses[0].topAppsSelectionPeriod,
      _applicationDetails: responses.map(response => applicationDetails(response))
    }
  }
}

class StatsTopAppsChartManager extends StatsSourceCollectorChartManager {
  static get Series () {
    return StatsTopAppsSeries
  }
}

class StatsTopAppsHelpText extends StatsUI {
  template () {
    if (this.period) {
      let since = moment(this.period.since).utcOffset(this.period.since).subtract(1, 'day').format('L')
      let until = moment(this.period.until).utcOffset(this.period.until).format('L')

      return (
        <p className='Stats-helptext Stats-message--notice'>
          Top Applications are determined from usage data between midnight {since} and midnight {until}
        </p>
      )
    } else {
      return <p></p>
    }
  }

  update (data) {
    this.period = data._topAppsSelectionPeriod
    this.refresh()
  }

  _bindEvents () {

  }

}

class StatsTopAppsChart extends StatsChart {
  _chartCustomOptions () {
    return {
      legend: {
        position: 'right'
      }
    }
  }
}

let statsTopApps = (serviceId, options = {}) => {
  let topAppsMetricsUrl = `/services/${serviceId}/stats/usage/top_applications.json`
  let metrics = StatsMetrics.getMetrics(topAppsMetricsUrl)
  let csvLink = new StatsCSVLink({container: options.csvLinkContainer})
  let helpText = new StatsTopAppsHelpText({container: options.helpTextContainer})
  let applicationsTable = new StatsApplicationsTable({container: options.tableContainer})

  Stats({ChartManager: StatsTopAppsChartManager, Chart: StatsTopAppsChart, Sources: StatsTopAppsSourceCollector}).build({
    id: serviceId,
    metrics,
    widgets: [csvLink, helpText, applicationsTable],
    options: {
      granularities: ['day', 'month'],
      hasGroupedMethods: false
    }
  })
}

export { statsTopApps, StatsTopAppsHelpText }
