import { StatsChart } from 'Stats/lib/chart'

const chart = new StatsChart({ container: '#chart' })

it('should format Y-axis as an integer', () => {
  expect(chart.chartOptions().axis.y.tick.format(0)).toBe('0')
  expect(chart.chartOptions().axis.y.tick.format(1)).toBe('1')
  expect(chart.chartOptions().axis.y.tick.format(42)).toBe('42')
  expect(chart.chartOptions().axis.y.tick.format(420)).toBe('420')
  expect(chart.chartOptions().axis.y.tick.format(1005)).toBe('1K')
  expect(chart.chartOptions().axis.y.tick.format(12700)).toBe('12.7K')
  expect(chart.chartOptions().axis.y.tick.format(1000100)).toBe('1M')
})

it.todo('renders a c3 chart')

it.todo('has the right options')

it.todo('update sends the right data to c3 chart')

it.todo('should plot the chart with the selected series')

it.todo('should select the right series')

it.todo('should display the no data message when no data is passed')
