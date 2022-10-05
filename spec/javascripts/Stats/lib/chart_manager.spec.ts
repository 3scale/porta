import $ from 'jquery'
import { StatsChartManager } from 'Stats/lib/chart_manager'

const statsState = {
  setState: jest.fn(),
  state: jest.fn()
}

const sources = {
  getSources: jest.fn()
}

const chart = {
  render: jest.fn(),
  update: jest.fn()
}

const metricsSelector = {
  render: jest.fn()
}

const chartManager = new StatsChartManager({ statsState, metricsSelector, sources, chart })
const data = {
  columns: [
    [
      'x',
      '2016-08-21T07:00:00'
    ],
    [
      'Hits',
      42
    ],
    [
      'Hots',
      69
    ]
  ],
  unload: true,
  _totalValues: 111
}

describe('ChartManager', () => {
  beforeEach((done) => {
    jest.spyOn(chartManager, '_getChartData')
      .mockResolvedValue(data)
    done()
  })

  it('should render chart with metrics selector and all series', (done) => {
    chartManager.renderChart().then(() => {
      expect(chart.render).toHaveBeenCalled()
      expect(chart.render).toHaveBeenCalledWith({ data, selectedSeries: ['Hits', 'Hots'] })
      done()
    })
  })

  it('should render chart with stored selected series', (done) => {
    jest.spyOn(chartManager, '_getStoredSelectedSeries')
      .mockImplementation(() => 'Hots')
    chartManager.renderChart().then(() => {
      expect(chart.render).toHaveBeenCalledWith({ data, selectedSeries: ['Hots'] })
      done()
    })
  })

  it('should update chart calling chart.update with data', (done) => {
    chartManager.updateChart().then(() => {
      expect(chart.update).toHaveBeenCalledWith(data)
      done()
    })
  })

  it('should set the correct state when updating series total', () => {
    chartManager._updateSeriesTotal(data)
    expect(statsState.setState).toHaveBeenCalledWith({ seriesTotal: 111 }, ['seriesTotal'], false)
  })

  // Todo: Implementation depends a lot on jQuery, testing without jQuery may require a refactor
  it('should update chart when refresh event was triggered', () => {
    jest.spyOn(chartManager, 'updateChart')
    $(statsState).trigger('refresh')

    expect(chartManager.updateChart).toHaveBeenCalled()
  })
})
