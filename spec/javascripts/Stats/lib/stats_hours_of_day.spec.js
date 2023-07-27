import { StatsHoursOfDayChart } from 'Stats/provider/stats_hours_of_day'

const chart = new StatsHoursOfDayChart({ container: '#chart' })

it('should format Y-axis as an integer', () => {
  expect(chart.chartOptions().axis.y.tick.format(0)).toBe('0')
  expect(chart.chartOptions().axis.y.tick.format(1)).toBe('1')
  expect(chart.chartOptions().axis.y.tick.format(42)).toBe('42')
  expect(chart.chartOptions().axis.y.tick.format(420)).toBe('420')
  expect(chart.chartOptions().axis.y.tick.format(1005)).toBe('1K')
  expect(chart.chartOptions().axis.y.tick.format(12700)).toBe('12.7K')
  expect(chart.chartOptions().axis.y.tick.format(1000100)).toBe('1M')
})
