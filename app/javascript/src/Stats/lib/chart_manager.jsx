import 'core-js/fn/symbol/index' // make Symbol work on IE 11
import $ from 'jquery'
import {StatsSeries} from './series'

export class StatsChartManager {
  constructor ({statsState, sources, chart, widgets = []}) {
    this.statsState = statsState
    this.Sources = sources
    this.chart = chart
    this.widgets = widgets

    this._bindEvents()
  }

  static get Series () {
    return StatsSeries
  }

  get sources () {
    return new Promise(resolve => resolve(this.Sources))
  }

  renderChart () {
    return this._processChart().then((data) => {
      let selectedSeries = data ? this._getSelectedSeries(data) : null
      return this.chart.render({data, selectedSeries})
    })
  }

  updateChart () {
    return this._processChart().then((data) => this.chart.update(data))
  }

  updateSeriesState (selectedSeries) {
    this.statsState.setState({selectedSeries: this._serializeSeries(selectedSeries)}, ['series'])
  }

  _processChart () {
    this._toggleLoading(true)
    return this._getChartData().then(data => {
      if (data) this._updateChartWidgets(data)
      this._toggleLoading(false)
      return data
    })
  }

  _getSelectedSeries (data) {
    let storedSelectedSeries = this._getStoredSelectedSeries()
    return storedSelectedSeries ? storedSelectedSeries.split(', ') : this._getMainSeries(data.columns)
  }

  _serializeSeries (series) {
    return series.map((serie) => serie.id).join(', ')
  }

  _getMainSeries (series) {
    let mainSeries = series.slice(1).map(serie => serie[0]).slice(0, 10)
    return mainSeries.length > 1 ? mainSeries : 'showAllSeries'
  }

  _getStoredSelectedSeries () {
    return this.statsState.state.selectedSeries
  }

  _toggleLoading (isVisible) {
    $(this.chart.chartContainer).toggleClass('is-loading', isVisible)
  }

  _getChartData () {
    return this.sources.then(sources => {
      if (sources.length > 0) {
        return this._buildSeries(sources).getData(this._options())
      } else {
        console.warn('[Stats] There are no sources to get data from')
        return false
      }
    })
  }

  _buildSeries (sources) {
    const Series = Object.getPrototypeOf(this).constructor.Series
    return new Series(sources)
  }

  _updateChartWidgets (data) {
    // TODO: Next refactor make all "widgets" dumb components + include the series total
    this._updateSeriesTotal(data)
    this.widgets.forEach(widget => widget.update(data))
  }

  _updateSeriesTotal (data) {
    let total = data._totalValues
    this.statsState.setState({seriesTotal: total}, ['seriesTotal'], false)
  }

  _bindEvents () {
    $(this.statsState).on('redraw refresh', () => this.updateChart())
  }

  _options () {
    return {
      dateRange: this.statsState.state.dateRange,
      selectedMetricName: this.statsState.state.selectedMetricName,
      timezone: this.statsState.state.timezone,
      selectedApplicationId: this.statsState.state.selectedApplicationId
    }
  }
}
