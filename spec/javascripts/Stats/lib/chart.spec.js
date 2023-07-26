import { StatsChart } from 'Stats/lib/chart'

describe('StatsChart', () => {
  const chart = new StatsChart({ container: '#chart' })

  it('Y-axis is formatted correctly', () => {
    expect(chart.chartOptions().axis.y.tick.format(12700)).toBe('12.7K')
    expect(chart.chartOptions().axis.y.tick.format(42)).toBe('42')
  })
})

it.todo('renders a c3 chart')

it.todo('has the right options')

it.todo('update sends the right data to c3 chart')

it.todo('should plot the chart with the selected series')

it.todo('should select the right series')

it.todo('should display the no data message when no data is passed')
