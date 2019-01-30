/** @jsx StatsUI.dom */
import {StatsUsageChart} from 'Stats/lib/usage_chart'
import {StatsUsageChartManager} from 'Stats/lib/usage_chart_manager'
import {StatsMetrics} from 'Stats/lib/metrics_list'
import {StatsSourceCollector} from 'Stats/lib/source_collector'
import {StatsMethodsTable} from 'Stats/lib/methods_table'
import {StatsApplicationMetricsSource} from 'Stats/lib/application_metrics_source'
import {StatsCSVLink} from 'Stats/lib/csv_link'
import {Stats} from 'Stats/lib/stats'
import $ from 'jquery'

export class StatsApplicationSourceCollector extends StatsSourceCollector {
  static get Source () {
    return StatsApplicationMetricsSource
  }

  getSources (options) {
    let id = options.selectedApplicationId
    let selectedMetricName = options.selectedMetricName
    return super.getSources({id, selectedMetricName})
  }
}

export class StatsApplicationChartManager extends StatsUsageChartManager {
  updateMetrics () {
    let id = this.statsState.state.selectedApplicationId
    let url = this._metricUrl(id)
    this.sourceCollector.getMetrics(url).then(list => this.metricsSelector.update(this._groupMetrics(list)))
  }

  _groupMetrics (list) {
    return [list.metrics[0], ...list.methods, ...list.metrics.slice(1)]
  }

  _bindEvents () {
    $(this.statsState).on('applicationSelected', () => { this.updateMetrics() })
    super._bindEvents()
  }

  _metricUrl (id) {
    return `/stats/applications/${id}/summary.json?version=2.0`
  }
}

let statsApplication = (applicationId, options = {}) => {
  let applicationMetricsUrl = `/stats/applications/${applicationId}/summary.json?version=2.0`
  let metrics = StatsMetrics.getMetrics(applicationMetricsUrl)
  let csvLink = new StatsCSVLink({container: options.csvLinkContainer})
  let methodsTable = new StatsMethodsTable({container: options.methodsTableContainer})

  Stats({ChartManager: StatsApplicationChartManager, Chart: StatsUsageChart, Sources: StatsApplicationSourceCollector}).build({
    id: applicationId,
    selectedState: {timezone: options.timezone},
    metrics,
    widgets: [csvLink, methodsTable],
    options

  })
}

export { statsApplication }
