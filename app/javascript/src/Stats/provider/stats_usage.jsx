/** @jsx StatsUI.dom */
import {StatsUsageChart} from '../lib/usage_chart'
import {PeriodRangeDate} from '../lib/state'
import {StatsUsageSourceCollector} from '../lib/usage_source_collector'
import {StatsMetrics} from '../lib/metrics_list'
import {StatsMethodsTable} from '../lib/methods_table'
import {StatsCSVLink} from '../lib/csv_link'
import {StatsUsageChartManager} from '../lib/usage_chart_manager'
import {Stats} from '../lib/stats'

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
