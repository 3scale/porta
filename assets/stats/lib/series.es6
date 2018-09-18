import 'core-js/fn/object/assign' // make Object.assign on IE 11
import 'core-js/fn/array/find-index' // make Object.findIndex on IE 11
import 'core-js/fn/array/find'
import moment from 'moment'
import 'moment-range'
import 'moment-timezone'

const CHART_TIMESTAMP_FORMAT = 'YYYY-MM-DDTHH:mm:ss'

export class StatsSeries {

  constructor (sources) {
    this.sources = sources
  }

  getData (options) {
    return Promise.all(this._getSourcesData(this.sources, options)).then(responses => this._seriesOptions(responses))
  }

  _getSourcesData (sources, options) {
    return sources.map(source => source.data(options))
  }

  _seriesOptions (responses) {
    let period = responses[0].period
    let timeAxis = ['x', ...this._parseTimePeriod(period)]
    let seriesData = this._sortResponses(responses).map(response => this._parseResponseData(response))
    return Object.assign({}, {
      columns: [
        timeAxis,
        ...seriesData
      ],
      unload: true,
      _period: period,
      _totalValues: this._totalValues(responses)
    },
    this._customOptions(responses)
    )
  }

  _parseResponseData (response) {
    let name = this._getSeriesName(response)
    return [
      name,
      ...response.values
    ]
  }

  _totalValues (responses) {
    return (responses.length > 1)
      ? responses.find(this._findMetricHits).total
      : responses[0].total
  }

  _getSeriesName (serie) {
    return serie.metric.name
  }

  _customOptions (responses) {
    return {}
  }

  _parseTimePeriod (period) {
    let range = []
    let granularity = period.granularity
    let timeInterval = `${period.since}/${period.until}`
    moment.range(timeInterval).by(granularity, moment => {
      range.push(moment.utc().tz(period.timezone).format(CHART_TIMESTAMP_FORMAT))
    })
    return range
  }

  _sortResponses (responses) {
    let hitsMetric = responses.find(this._findMetricHits)
    if (responses.length > 1 && hitsMetric) {
      let sortedResponses = responses.sort((a, b) => b.total - a.total)
      responses.splice(responses.findIndex(response => response === hitsMetric), 1)
      sortedResponses.unshift(hitsMetric)
      return sortedResponses
    } else {
      return responses
    }
  }

  _findMetricHits (response) {
    if (response.metric) {
      return response.metric.system_name === 'hits'
    } else {
      return null
    }
  }
}
