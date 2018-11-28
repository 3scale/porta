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

  getSources (options) {
    let id = options.selectedApplicationId
    let selectedMetricName = options.selectedMetricName
    let requestNew = (id && id !== this.id)
    let url

    if (requestNew) url = this._metricUrl(id)

    return super.getSources({id, selectedMetricName, url})
  }

  _metricUrl (id) {
    return `/stats/applications/${id}/summary.json?version=2.0`
  }
}

let statsApplication = (applicationId, options = {}) => {
  let version = 2.0 // Needed to identify new version, some people is still using old charts https://github.com/3scale/system/issues/7769
  let applicationMetricsUrl = `/stats/applications/${applicationId}/summary.json?version=${version}`
  let metrics = StatsMetrics.getMetrics(applicationMetricsUrl)
  let csvLink = new StatsCSVLink({container: options.csvLinkContainer})
  let methodsTable = new StatsMethodsTable({container: options.methodsTableContainer})

  Stats({ChartManager: StatsUsageChartManager, Chart: StatsUsageChart, Sources: StatsApplicationSourceCollector}).build({
    id: applicationId,
    selectedState: {timezone: options.timezone},
    metrics,
    widgets: [csvLink, methodsTable],
    options

  })
}

export { statsApplication }
