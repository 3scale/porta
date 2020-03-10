import $ from 'jquery'
import moment from 'moment'
import c3 from 'c3'
import numeral from 'numeral'

export class StatsChart {
  constructor ({container}) {
    this.chartContainer = container
  }

  render ({data, selectedSeries}) {
    this.plotChart = this._renderChart()
    $(this.chartContainer).data('chart', this.plotChart)
    this._appendNoDataAvailableMessage()
    this.update(data)
    this._showSelectedSeries(selectedSeries)
  }

  chartOptions () {
    return Object.assign(
      {},
      {
        bindto: this.chartContainer,
        axis: {
          x: {
            type: 'timeseries',
            tick: {
              format: x => this._humanDatePresenter(x)
            }
          },
          y: {
            tick: {
              format: d => numeral(d).format('0.0a').toUpperCase()
            }
          }
        },
        data: {
          type: 'spline',
          x: 'x',
          xFormat: '%Y-%m-%dT%H:%M:%S',
          columns: [
            ['x'],
            ['loading...']
          ]
        },
        point: {
          r: 4
        },
        grid: {
          y: {
            show: true
          }
        },
        legend: {
          position: 'right',
          item: {
            onclick: id => this.selectChartSerie(id)
          }
        }
      },
      this._chartCustomOptions()
    )
  }

  selectChartSerie (id) {
    this.plotChart.toggle(id)
    let selectedSeries = this.plotChart.data.shown()
    this.manager.updateSeriesState(selectedSeries)
  }

  update (data) {
    let dataPresent = data && data._totalValues && data._totalValues > 0
    dataPresent ? this._updateChart(data) : this._flushChart()
    this.showData(dataPresent)
  }

  showData (dataPresent) {
    $(this.noDataMessage).toggleClass('is-hidden', dataPresent)
    return dataPresent
  }

  registerManager (manager) {
    this.manager = manager
  }

  _renderChart () {
    return c3.generate(this.chartOptions())
  }

  _showSelectedSeries (selectedSeries = 'showAllSeries') {
    if (selectedSeries !== 'showAllSeries') {
      this.plotChart.hide()
      this.plotChart.show(selectedSeries)
    }
  }

  _chartCustomOptions () {
    return {}
  }

  _updateChart (data) {
    data.columns = this._limitChartData(data.columns)
    this.plotChart.load(data)
  }

  _flushChart () {
    this.plotChart.flush()
    this.plotChart.unload()
  }

  _limitChartData (data) {
    return data.slice(0, 17)
  }

  _humanDatePresenter (date) {
    return moment(date).format('MMM D HH:mm')
  }

  _appendNoDataAvailableMessage () {
    this.noDataMessage = $('<p class="Stats-message--notice is-hidden">There is no data available for the selected period</p>')
    $(this.chartContainer).after(this.noDataMessage)
  }
}
