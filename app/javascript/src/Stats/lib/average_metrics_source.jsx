import 'core-js/fn/object/assign' // make Object.assign work on IE 11
import 'core-js/modules/es6.map' // make Maps work on IE 11
import Moment from 'moment'
import { extendMoment } from 'moment-range'
import {StatsMetricsSource} from 'Stats/lib/metrics_source'

const moment = extendMoment(Moment)

export class StatsAverageMetricsSource extends StatsMetricsSource {
  get url () {
    return `/stats/api/services/${this.id}/usage.json`
  }

  _processResponse (response, options) {
    return Object.assign({}, response, {values: this._average(response.values, options)})
  }

  _average (responseValues, stateOptions) {
    const period = stateOptions.dateRange
    const range = moment.range(period.since, period.until)
    let dataMap = new Map()
    let i = 0
    Array.from(range.by(period.granularity)).forEach(current => {
      let key = current[period.granularity]()
      let storedValue = dataMap.get(key) || 0
      let value = storedValue + ((responseValues.length > i) ? responseValues[i] : 0)
      dataMap.set(key, value)
      i++
    })
    let sortedValues = this._sortValues(dataMap)
    return sortedValues.map((value) => Math.ceil(value / sortedValues.length))
  }

  _sortValues (map) {
    let keys = []
    let sortedValues = []
    let mapKeys = map.keys()
    for (let key of mapKeys) { keys.push(key) }
    keys.sort((a, b) => a - b)
    for (let i = 0, len = keys.length; i < len; i++) {
      sortedValues.push(map.get(keys[i]))
    }
    return sortedValues
  }
}
