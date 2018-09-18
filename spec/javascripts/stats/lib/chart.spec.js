import $ from 'jquery'

import {StatsChart} from 'stats/lib/chart'

describe('StatsChart', function () {
  let chart = new StatsChart({container: '#chart'})

  let data = {
    columns: [
      [
        'x',
        '2016-08-13T07:00:00'
      ],
      [
        'Hits',
        42
      ],
      [
        'Hertz',
        440
      ]
    ],
    unload: true,
    _totalValues: 42
  }

  beforeEach(() => {
    fixture.set('<div id="chart"></div>')
    chart.render({data, selectedSeries: ['Hits']})
  })

  it('renders a c3 chart', () => {
    let $chart = $('#chart')

    expect(chart.plotChart).toBeDefined()
    expect(chart.plotChart.constructor.name).toBe('Chart')
    expect($chart).toBeInDOM()
    expect($chart).toHaveClass('c3')
  })

  it('has the right options', () => {
    const expectedOptions = ['axis', 'bindto', 'data', 'grid', 'legend', 'point'].sort()
    let options = Object.keys(chart.chartOptions()).sort()

    expect(options).toEqual(expectedOptions)
  })

  it('update sends the right data to c3 chart', () => {
    spyOn(chart, '_updateChart')
    chart.update(data)

    expect(chart._updateChart).toHaveBeenCalledWith(
      {
        columns: [ [ 'x', '2016-08-13T07:00:00' ], [ 'Hits', 42 ], [ 'Hertz', 440 ] ],
        unload: true,
        _totalValues: 42
      }
    )
  })

  it('should plot the chart with the selected series', () => {
    expect(chart.plotChart.data.shown().length).toBe(1)
    expect(chart.plotChart.data.shown()[0].id).toBe('Hits')
  })

  it('should select the right series', () => {
    chart.manager = { updateSeriesState: () => {} }
    spyOn(chart.manager, 'updateSeriesState')

    chart.selectChartSerie('Hertz')
    expect(chart.plotChart.data.shown().length).toBe(2)
    expect(chart.manager.updateSeriesState).toHaveBeenCalled()
  })

  it('should display the no data message when no data is passed', () => {
    spyOn(chart, '_flushChart')
    chart.update(null)

    expect(chart.noDataMessage).toContainText('There is no data available for the selected period')
    expect(chart._flushChart).toHaveBeenCalled()
  })
})
