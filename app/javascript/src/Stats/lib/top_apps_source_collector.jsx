import * as helpers from 'Stats/lib/stats_helpers'
import {StatsSourceCollector} from 'Stats/lib/source_collector'
import {StatsTopApplicationMetricsSource} from 'Stats/lib/top_application_metrics_source'

export class StatsTopAppsSourceCollector extends StatsSourceCollector {
  static get Source () {
    return StatsTopApplicationMetricsSource
  }

  get url () {
    return `/stats/services/${this.id}/top_applications.json`
  }

  params ({dateRange, selectedMetricName}) {
    return Object.assign({},
      super.params({dateRange, selectedMetricName}),
      {period: helpers.getPeriodFromDateRange(dateRange)}
    )
  }

  getSources ({dateRange, selectedMetricName}) {
    let metrics = this.metrics
    return this._sourcesRequest({dateRange, selectedMetricName}).then(sources => {
      return Promise.all(sources.applications.map(source => {
        return this._resolveSources({id: source.id, selectedMetricName, metrics})
          .then(builtSources => this._addSelectionPeriodToSource(builtSources[0], sources.period))
      }))
    })
  }

  _addSelectionPeriodToSource (source, period) {
    source.topAppsSelectionPeriod = period
    return source
  }
}
