import $ from 'jquery'
import { StatsMetric } from 'Stats/lib/metric'

export class StatsMetrics {
  static getMetrics (url) {
    return this._makeRequest(url).then(response => this._parseResponse(response))
  }

  static getSelectedMetrics ({ selectedMetricName, list }) {
    const listMethods = list.methods || []
    const selectedMetric = (list.metrics.concat(listMethods)).find(metric => metric.systemName === selectedMetricName)
    const methodsOfSelectedMetric = listMethods.filter(method => method.parentId === selectedMetric.id)
    return (selectedMetric.isHits && methodsOfSelectedMetric.length > 0)
      ? [selectedMetric, ...methodsOfSelectedMetric]
      : [selectedMetric]
  }

  static _makeRequest (url) {
    return new Promise((resolve, reject) => {
      $.getJSON(url)
        .done(response => resolve(response))
        .fail((xhr, status, error) => reject(new Error(`Request failed: ${status}, ${error}`)))
    })
  }

  static _parseResponse (response) {
    let parsedResponse = {}
    for (let metric in response) {
      parsedResponse[metric] = response[metric].map(m => new StatsMetric(m.metric))
    }
    return parsedResponse
  }
}
