import $ from 'jquery'
import {StatsChartManager} from '../../../app/javascript/src/Stats/lib/chart_manager'

let statsState = jasmine.createSpyObj('statsState', ['setState', 'state'])
let sources = jasmine.createSpyObj('sources', ['getSources'])
let chart = jasmine.createSpyObj('chart', ['render', 'update'])

let chartManager = new StatsChartManager({statsState, sources, chart})
let data = {
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
    spyOn(chartManager, '_getChartData').and.callFake(() => {
      return new Promise((resolve) => {
        resolve(data)
      })
    })
    done()
  })

  it('should render chart with all series', (done) => {
    chartManager.renderChart('#container').then(() => {
      expect(chart.render).toHaveBeenCalledWith({data, selectedSeries: ['Hits', 'Hots']})
      done()
    })
  })

  it('should render chart with stored selected series', (done) => {
    spyOn(chartManager, '_getStoredSelectedSeries').and.returnValue('Hots')
    chartManager.renderChart('#container').then(() => {
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
    expect(statsState.setState).toHaveBeenCalledWith({seriesTotal: 111}, [ 'seriesTotal' ], false)
  })

  it('should update chart when refresh event was triggered', () => {
    spyOn(chartManager, 'updateChart')
    $(statsState).trigger('refresh')

    expect(chartManager.updateChart).toHaveBeenCalled()
  })
})
