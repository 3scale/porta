import { StatsUsageChart } from 'Stats/lib/usage_chart'

describe('StatsUsageChart', () => {
  let chart = new StatsUsageChart({container: '#chart', groupedSeries: ['marvin', 'trillian', 'zaphod']})
  const plotChart = {
    load: jest.fn()
  }
  chart.plotChart = plotChart
  const spy = jest.spyOn(plotChart, 'load')

  afterEach(() => {
    jest.clearAllMocks()
  })

  it('should be a bar chart', () => {
    expect(chart.chartOptions().data.type).toBe('bar')
  })

  it('should be a spline type for the metric', () => {
    let stubbedData = {
      columns: [
        ['x', '2016-12-19'],
        ['Hits', 42],
        ['method 1', 0],
        ['method 2', 0],
        ['method 3', 0]
      ]
    }

    chart._updateChart(stubbedData)
    expect(spy).toHaveBeenCalledWith({
      columns: [['x', '2016-12-19'], ['Hits', 42], ['method 1', 0], ['method 2', 0], ['method 3', 0]],
      type: 'bar',
      types: {
        'Hits': 'spline'
      }
    })
  })

  it('should call plotChart.load once when updating data', () => {
    chart._updateChart({columns: [['x', '2017-01-01'], ['Lola', 40], ['Simon', 2]]})
    expect(spy).toHaveBeenCalledTimes(1)
    expect(spy).not.toHaveBeenCalledTimes(2)
  })

  it('should have the right grouped data', () => {
    expect(JSON.stringify(chart.chartOptions().data.groups)).toBe(JSON.stringify([ [ 'marvin', 'trillian', 'zaphod' ] ]))
  })
})
