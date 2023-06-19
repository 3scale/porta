/** @jsx StatsUI.dom */
import { StatsApplicationMetricsSource } from 'Stats/lib/application_metrics_source'
import { StatsCSVLink } from 'Stats/lib/csv_link'
import { StatsMethodsTable } from 'Stats/lib/methods_table'
import { StatsMetrics } from 'Stats/lib/metrics_list'
import { StatsSourceCollector } from 'Stats/lib/source_collector'
import { Stats } from 'Stats/lib/stats'
import { StatsUsageChart } from 'Stats/lib/usage_chart'
import { StatsUsageChartManager } from 'Stats/lib/usage_chart_manager'

export class StatsApplicationSourceCollector extends StatsSourceCollector {
  static get Source () {
    return StatsApplicationMetricsSource
  }
}

let statsApplication = (applicationId, options = {}) => {
  let applicationMetricsUrl = `/buyers/stats/applications/${applicationId}.json`
  let metrics = StatsMetrics.getMetrics(applicationMetricsUrl)
  let csvLink = new StatsCSVLink({ container: options.csvLinkContainer })
  let methodsTable = new StatsMethodsTable({ container: options.methodsTableContainer })

  Stats({ ChartManager: StatsUsageChartManager, Chart: StatsUsageChart, Sources: StatsApplicationSourceCollector }).build({
    id: applicationId,
    metrics,
    widgets: [csvLink, methodsTable]

  })
}

export { statsApplication }
