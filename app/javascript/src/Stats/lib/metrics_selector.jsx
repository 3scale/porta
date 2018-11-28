/** @jsx StatsUI.dom */
import $ from 'jquery'
import numeral from 'numeral'
import 'core-js/fn/array/find'

import {StatsUI} from './ui'

export class StatsMetricsSelector extends StatsUI {
  constructor ({statsState, metrics, container}) {
    super({statsState, container})
    this.metrics = metrics

    this._bindEvents()
  }

  template () {
    let metrics = this.metrics
    let selectedMetricName = this.statsState.state.selectedMetricName
    let selectedMetric = metrics.find(metric => metric.systemName === selectedMetricName)
    let total = this.statsState.state.seriesTotal

    return (
      <div className={`StatsSelector ${this.open ? 'is-open' : ''}`}>
        <button onclick={ev => this._toggleOpen()} className='StatsSelector-item StatsSelector-toggle'>
          {numeral(total).format('0.0a').toUpperCase()} {selectedMetric.name}
        </button>
        <ul className='StatsSelector-menu'>
          {
            metrics.map(metric =>
              [
                <li><a onclick={ ev => this.selectMetric(metric)}
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

  _setState (state, topics) {
    super._setState(state, topics)
    this._toggleOpen()
  }

  _bindEvents () {
    $(this.statsState).on('redraw seriesTotal', () => { this.refresh() })
  }

  _toggleOpen () {
    this.open = !this.open
    this.refresh()
  }

}
