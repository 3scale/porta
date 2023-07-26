import { StatsMetricsSelector } from 'Stats/lib/metrics_selector'

const metricsSelector = (totalHits) => {
  const userSelectedState = {
    state: {
      selectedMetricName: 'pierogi',
      seriesTotal: totalHits
    },
    setState: jest.fn()
  }

  const metrics = [
    { id: 42, name: 'Pierogi', systemName: 'pierogi' },
    { id: 666, name: 'Choripanes', systeName: 'choripanes' }
  ]

  return new StatsMetricsSelector({ statsState: userSelectedState, metrics, container: '#selector' })
}
describe('StatsMetricsSelector', () => {

  beforeEach(() => {
    document.body.innerHTML = '<div id="selector"></div>'
  })

  it('should render the right selector', () => {
    const totalHits = 42500
    metricsSelector(totalHits).render()

    expect(document.querySelector('.StatsSelector-toggle')).toBeTruthy()
    expect(document.querySelector('.StatsSelector-menu')).toBeTruthy()
    expect(document.querySelector('.StatsSelector-toggle').innerHTML).toContain('42.5K Pierogi')
    expect(document.querySelectorAll('.StatsSelector-menu > li')).toHaveLength(2)
  })

  it('should format the number correctly', () => {
    const totalHits = 345
    metricsSelector(totalHits).render()

    expect(document.querySelector('.StatsSelector-toggle').innerHTML).toContain('345 Pierogi')
  })
})
