/** @jsx StatsUI.dom */
import {StatsUsageChart} from 'Stats/lib/usage_chart'
import {PeriodRangeDate} from 'Stats/lib/state'
import {StatsUsageSourceCollector} from 'Stats/lib/usage_source_collector'
import {StatsMetrics} from 'Stats/lib/metrics_list'
import {StatsMethodsTable} from 'Stats/lib/methods_table'
import {StatsCSVLink} from 'Stats/lib/csv_link'
import {StatsUsageChartManager} from 'Stats/lib/usage_chart_manager'
import {Stats} from 'Stats/lib/stats'

const DEFAULT_METRIC = 'hits'

let statsUsage = (serviceId, options = {}) => {
  let selectedState = { dateRange: new PeriodRangeDate(), selectedMetricName: DEFAULT_METRIC }
  let usageMetricsUrl = `/services/${serviceId}/stats/usage.json`
  let metrics = StatsMetrics.getMetrics(usageMetricsUrl)
  let csvLink = new StatsCSVLink({container: options.csvLinkContainer})
  let methodsTable = new StatsMethodsTable({container: options.methodsTableContainer})

  Stats({ChartManager: StatsUsageChartManager, Chart: StatsUsageChart, Sources: StatsUsageSourceCollector}).build({
    id: serviceId,
    selectedState,
    metrics,
    widgets: [csvLink, methodsTable]

  })
}

export { statsUsage }
