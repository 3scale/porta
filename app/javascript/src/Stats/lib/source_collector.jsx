import $ from 'jquery'
import 'core-js/fn/array/find'

import {StatsMetrics} from 'Stats/lib/metrics_list'

export class StatsSourceCollector {
  constructor ({id, metrics}) {
    this.id = id
    this.metricsPromise = metrics
  }

  static get Source () {
    throw new Error('It should implement getter in subclasses.')
  }

  get url () {
    throw new Error('It should implement url getter in subclasses.')
  }

  get metrics () {
    return this.metricsPromise
  }

  set metrics (metrics) {
    this.metricsPromise = metrics
  }

  getMetrics (url) {
    let metricsPromise = StatsMetrics.getMetrics(url)
    this.metrics = metricsPromise
    return metricsPromise
  }

  getSources ({id, selectedMetricName}) {
    let selectedId = id || this.id
    return this._resolveSources({id: selectedId, selectedMetricName, metrics: this.metrics})
  }

  params ({dateRange, selectedMetricName}) {
    return {
      metric_name: selectedMetricName,
      granularity: dateRange.granularity,
      since: dateRange.since,
      until: dateRange.until,
      skip_change: true
    }
  }

  buildSources (id, metrics) {
    const Source = Object.getPrototypeOf(this).constructor.Source
    return metrics.map(metricDetails => new Source({id, details: metricDetails}))
  }

  _resolveSources ({id, selectedMetricName, metrics}) {
    return metrics.then(list => {
      let selectedMetrics = StatsMetrics.getSelectedMetrics({selectedMetricName, list})
      return this.buildSources(id, selectedMetrics)
    })
  }

  _sourcesRequest (options) {
    return new Promise((resolve, reject) => {
      $.getJSON(this.url, this.params(options))
        .then(response => resolve(response))
        .fail((xhr, status, error) => reject(new Error(`Request failed: ${status}, ${error}`)))
    })
  }
}
