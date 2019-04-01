/** @jsx StatsUI.dom */
import $ from 'jquery'
import numeral from 'numeral'

import {StatsUI} from 'Stats/lib/ui'

export class StatsMetricsSelector extends StatsUI {
  constructor ({statsState, metrics, container}) {
    super({statsState, container})
    this.metricsList = metrics
    this._bindEvents()
  }

  get metrics () {
    return this.metricsList
  }

  set metrics (metrics) {
    this.metricsList = metrics
  }

  template () {
    let metrics = this.metrics
    let selectedMetricName = this.statsState.state.selectedMetricName
    let selectedMetric = metrics.find(metric => metric.systemName === selectedMetricName)
    let total = this.statsState.state.seriesTotal

    return (
      <div className={`StatsSelector ${this.open ? 'is-open' : ''}`}>
        <button onclick={ev => this._toggleOpen(!this.open)} className='StatsSelector-item StatsSelector-toggle'>
          {numeral(total).format('0.0a').toUpperCase()} {selectedMetric.name}
        </button>
        <ul className='StatsSelector-menu'>
          {
            metrics.map(metric =>
              [
                <li><a onclick={ ev => { this.selectMetric(metric); this._toggleOpen(false) }}
                  className={`StatsSelector-item ${metric.isMethod ? 'is-children' : ''} ${selectedMetric.name === metric.name ? 'is-selected' : ''}`}
                >{metric.name}
                </a></li>
              ]
            )
          }
        </ul>
      </div>
    )
  }

  selectMetric (metric) {
    this._setState({selectedMetricName: metric.systemName}, ['redraw'])
  }

  update (metrics) {
    this.metrics = metrics
    this.selectMetric(metrics[0])
    this._toggleOpen(false)
    this.refresh()
  }

  _setState (state, topics) {
    super._setState(state, topics)
  }

  _bindEvents () {
    $(this.statsState).on('redraw seriesTotal', () => { this.refresh() })
  }

  _toggleOpen (toggle) {
    this.open = toggle
    this.refresh()
  }
}
