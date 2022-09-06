/** @jsx StatsUI.dom */
import { StatsUsageChart } from 'Stats/lib/usage_chart'
import { PeriodRangeDate } from 'Stats/lib/state'
import { StatsUsageSourceCollector } from 'Stats/lib/usage_source_collector'
import { StatsUsageBackendApiSourceCollector } from 'Stats/lib/usage_backend_api_source_collector'
import { StatsMetrics } from 'Stats/lib/metrics_list'
import { StatsMethodsTable } from 'Stats/lib/methods_table'
import { StatsCSVLink } from 'Stats/lib/csv_link'
import { StatsUsageChartManager } from 'Stats/lib/usage_chart_manager'
import { Stats } from 'Stats/lib/stats'

let statsUsage = (serviceOrBackendId, options = {}) => {
  let selectedState = { dateRange: new PeriodRangeDate(), selectedMetricName: options.hitsMetricName }
  let metrics = StatsMetrics.getMetrics(options.usageMetricsUrl)
  let csvLink = new StatsCSVLink({ container: options.csvLinkContainer })
  let methodsTable = new StatsMethodsTable({ container: options.methodsTableContainer })
  let sources = (options.sourceCollection === 'backend_api') ? StatsUsageBackendApiSourceCollector : StatsUsageSourceCollector

  Stats({ ChartManager: StatsUsageChartManager, Chart: StatsUsageChart, Sources: sources }).build({
    id: serviceOrBackendId,
    selectedState,
    metrics,
    widgets: [csvLink, methodsTable]
  })
}

export { statsUsage }
