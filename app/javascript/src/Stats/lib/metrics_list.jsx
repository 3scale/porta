import $ from 'jquery'
import {StatsMetric} from './metric'

export class StatsMetrics {
  static getMetrics (url) {
    return this._makeRequest(url).then(response => this._parseResponse(response))
  }

  static getSelectedMetrics ({selectedMetricName, list}) {
    let selectedMetric = list.metrics.find(metric => metric.systemName === selectedMetricName)
    return (selectedMetricName === 'hits' && list.methods.length > 0)
      ? [selectedMetric, ...list.methods]
      : [selectedMetric]
  }

  static _makeRequest (url) {
    return new Promise((resolve, reject) => {
      $.getJSON(url)
        .done(response => resolve(response))
        .fail((xhr, status, error) => reject(`Request failed: ${status}, ${error}`))
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
