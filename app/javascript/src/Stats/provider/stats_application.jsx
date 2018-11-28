/** @jsx StatsUI.dom */
import {StatsUsageChart} from '../lib/usage_chart'
import {StatsUsageChartManager} from '../lib/usage_chart_manager'
import {StatsMetrics} from '../lib/metrics_list'
import {StatsSourceCollector} from '../lib/source_collector'
import {StatsMethodsTable} from '../lib/methods_table'
import {StatsApplicationMetricsSource} from '../lib/application_metrics_source'
import {StatsCSVLink} from '../lib/csv_link'
import {Stats} from '../lib/stats'

export class StatsApplicationSourceCollector extends StatsSourceCollector {
  static get Source () {
    return StatsApplicationMetricsSource
  }
}

let statsApplication = (applicationId, options = {}) => {
  let applicationMetricsUrl = `/buyers/stats/applications/${applicationId}.json`
  let metrics = StatsMetrics.getMetrics(applicationMetricsUrl)
  let csvLink = new StatsCSVLink({container: options.csvLinkContainer})
  let methodsTable = new StatsMethodsTable({container: options.methodsTableContainer})

  Stats({ChartManager: StatsUsageChartManager, Chart: StatsUsageChart, Sources: StatsApplicationSourceCollector}).build({
    id: applicationId,
    metrics,
    widgets: [csvLink, methodsTable]

  })
}

export { statsApplication }
