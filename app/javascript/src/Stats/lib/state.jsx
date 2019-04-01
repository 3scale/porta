import $ from 'jquery'
import moment from 'moment'

export class StatsState {
  constructor (store, state) {
    this.store = store
    this.State = state

    this.getInitialState()
    this._bindEvents()
  }

  set state (state) {
    this.State = Object.assign({}, this.State, state)
  }

  get state () {
    return this.State
  }

  getInitialState () {
    let state = this.getStoredState()
    state ? this.setState(state, ['initial'], false) : this.setState(this._defaultState(), ['default'])
  }

  getStoredState () {
    let params = this.store.getStateFromURL()
    if (params) return this._processStoredState(params)
  }

  setState (state, topics = ['refresh'], store = true) {
    this.state = state
    if (store) this._storeState(this.state)
    topics.forEach((topic) => { $(this).triggerHandler(topic) })
  }

  _defaultState () {
    return this.state || { dateRange: new PeriodRangeDate() }
  }

  _storeState (state) {
    this.store.save(state)
  }

  _processStoredState (params) {
    if ('period' in params.dateRange) {
      return Object.assign({}, params, {dateRange: new PeriodRangeDate(params.dateRange.period)})
    } else {
      return Object.assign({}, params, {dateRange: new CustomRangeDate(params.dateRange)})
    }
  }

  _bindEvents () {
    $(this.store).on('navigation', () => this.setState(this.getStoredState(), ['refresh'], false))
  }
}

const MACHINE_DATE_FORMAT = 'YYYY-MM-DDTHH:mm:ss'
const RANGE_CORRECTOR = 1

export class CustomRangeDate {
  constructor ({Since, Until, granularity}) {
    this.Since = Since
    this.Until = Until
    this.granularity = granularity
  }

  get since () {
    return moment(this.Since).startOf('day').format(MACHINE_DATE_FORMAT)
  }

  set since (date) {
    this.Since = moment(date).format(MACHINE_DATE_FORMAT)
  }

  get until () {
    return moment(this.Until).endOf('day').format(MACHINE_DATE_FORMAT)
  }

  set until (date) {
    this.Until = moment(date).format(MACHINE_DATE_FORMAT)
  }
}

export class PeriodRangeDate {
  constructor (period = { number: 24, unit: 'hour' }) {
    this.period = period
    this.granularity = period.granularity || period.unit
  }

  get since () {
    let date = moment().utc().subtract(this.period.number - RANGE_CORRECTOR, this.period.unit)
    return this._formatDate(date)
  }

  get until () {
    let date = moment().utc()
    return this._formatDate(date)
  }

  _formatDate (date) {
    // Only when the granularity desired is hour we set the offset with Moment.format()
    return (this.period.unit === 'hour') ? date.format() : date.format(MACHINE_DATE_FORMAT)
  }
}
