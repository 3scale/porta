import 'core-js/fn/object/assign' // make Object.assign on IE 11
import {StatsChart} from 'Stats/lib/chart'

export class StatsUsageChart extends StatsChart {
  constructor ({container, groupedSeries = []}) {
    super({container})
    this.groupedSeries = groupedSeries
  }

  _chartCustomOptions () {
    return {
      data: {
        colors: function (color, d) {
          return d.index && d.index === 1 ? '#4A90E2' : color
        },
        type: 'bar',
        x: 'x',
        xFormat: '%Y-%m-%dT%H:%M:%S',
        columns: [
          ['x'],
          ['loading...']
        ],
        groups: [this.groupedSeries]
      }
    }
  }

  _updateChart (data) {
    data.columns = this._limitChartData(data.columns)
    this.plotChart.load(this._addMetricDataStyle(data))
  }

  _addMetricDataStyle (data) {
    return Object.assign({}, data, {
      type: 'bar',
      types: {
        [this._metricName(data)]: 'spline'
      }
    })
  }

  _metricName (data) {
    return data.columns[1][0]
  }
}
