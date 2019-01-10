import 'core-js/fn/object/assign' // make Object.assign on IE 11
import $ from 'jquery'

import {StatsChart} from 'Stats/lib/chart'
import {StatsChartManager} from 'Stats/lib/chart_manager'
import {StatsState, PeriodRangeDate} from 'Stats/lib/state'
import {StatsStore} from 'Stats/lib/store'
import {StatsMetricsSource} from 'Stats/lib/metrics_source'
import {StatsSeries} from 'Stats/lib/series'
import {StatsMenu} from 'Stats/lib/menu'

const OPTIONS = {
  metrics: [
    { system_name: '2XX' },
    { system_name: '4XX' },
    { system_name: '5XX' }
  ]
}

const DEFAULT_CODES = '2XX, 4XX, 5XX'

class StatsResponseCodeSeries extends StatsSeries {
  _getSeriesName (serie) {
    return serie.response_code.code
  }

  _totalValues (responses) {
    return responses.map((response) => response.total).reduce((previous, current) => previous + current, 0)
  }
}

class StatsResponseCodeChartManager extends StatsChartManager {
  static get Series () {
    return StatsResponseCodeSeries
  }

  renderChart (noDataMessageContainer) {
    this._processChart().then(data => this.chart.render({noDataMessageContainer, data}))
  }
}

class StatsResponseCodeChart extends StatsChart {
  constructor ({container, statsState}) {
    super({container})
    this.statsState = statsState
  }

  render ({noDataMessageContainer, data}) {
    this.noDataMessageContainer = noDataMessageContainer
    $(this.noDataMessageContainer).addClass('is-hidden')
    super.render({data})
    this._showSelectedSeries()
  }

  updateFromSeries (series, topics = ['series']) {
    this.statsState.setState({code: series}, topics)
  }

  showData (dataPresent) {
    $(this.chartContainer).toggleClass('is-hidden', !dataPresent)
    $(this.noDataMessageContainer).toggleClass('is-hidden', dataPresent)
  }

  _showSelectedSeries () {
    let selectedSeries = this.statsState.state.code.split(', ')
    this.plotChart.hide()
    this.plotChart.show(selectedSeries)
  }

  _chartCustomOptions () {
    let chart = this
    return {
      data: {
        type: 'area-spline',
        x: 'x',
        xFormat: '%Y-%m-%dT%H:%M:%S',
        columns: [
          ['x'],
          ['2XX'],
          ['4XX'],
          ['5XX']
        ],
        colors: {
          '2XX': '#5CB85C',
          '4XX': '#F0AD4E',
          '5XX': '#D9534F'
        },
        groups: [['2XX', '4XX', '5XX']]
      },
      legend: {
        item: {
          onclick: function (id) {
            chart.plotChart.toggle(id)
            let selectedSeries = chart.plotChart.data.shown().map((serie) => serie.id).join(', ')
            chart.updateFromSeries(selectedSeries)
          }
        }
      }
    }
  }
}

class StatsResponseCodeSource extends StatsMetricsSource {
  get url () {
    return `/stats/services/${this.id}/usage_response_code.json`
  }

  params ({dateRange}) {
    return {
      response_code: this.details.system_name,
      granularity: dateRange.granularity,
      since: dateRange.since,
      until: dateRange.until,
      skip_change: true
    }
  }
}

let statsResponseCodes = (serviceId, options = {}) => {
  let defaults = {
    chartContainer: '#chart',
    menuContainer: '.StatsMenu-container',
    noDataMessageContainer: '.StatsChart-noDataMessageContainer',
    utcOffset: 0
  }

  let settings = Object.assign({}, defaults, options)
  let store = new StatsStore(window)
  let statsState = new StatsState(store, { dateRange: new PeriodRangeDate(), code: DEFAULT_CODES })
  let sources = OPTIONS.metrics.map((metric) => new StatsResponseCodeSource({id: serviceId, details: metric}))
  let chart = new StatsResponseCodeChart({container: settings.chartContainer, statsState})

  const PERIODS = [
    { number: 24, unit: 'hour' },
    { number: 7, unit: 'day' },
    { number: 30, unit: 'day' },
    { number: 12, unit: 'month' }
  ]

  new StatsMenu({statsState, periods: PERIODS, container: settings.menuContainer}).render()

  new StatsResponseCodeChartManager({
    statsState,
    sources,
    chart
  }).renderChart(settings.noDataMessageContainer)
}

export { statsResponseCodes, StatsResponseCodeSource, StatsResponseCodeChart }
