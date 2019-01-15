import $ from 'jquery'

import {StatsSource} from 'Stats/lib/source'

export class StatsMetricsSource extends StatsSource {
  constructor ({id, details = {}}) {
    super()
    this.details = details
    this.id = id
  }

  params ({dateRange, selectedMetricName = 'hits', timezone = undefined}) {
    let metricName = (this.details.systemName && selectedMetricName === 'hits')
      ? this.details.systemName
      : selectedMetricName
    return {
      metric_name: metricName,
      granularity: dateRange.granularity,
      since: dateRange.since,
      until: dateRange.until,
      timezone,
      skip_change: true
    }
  }

  data (options) {
    return new Promise((resolve, reject) => {
      this.request = $.getJSON(this.url, this.params(options))
        .done(response => resolve(this._processResponse(response, options)))
        .fail((xhr, status, error) => reject(new Error(`Request failed: ${status}, ${error}`)))
    })
  }

  _processResponse (response, _options) {
    return response
  }
}
