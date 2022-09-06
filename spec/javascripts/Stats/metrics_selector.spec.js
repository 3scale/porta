import { StatsMetricsSelector } from 'Stats/lib/metrics_selector'

describe('StatsMetricsSelector', () => {
  let userSelectedState = {
    state: {
      selectedMetricName: 'pierogi',
      seriesTotal: 42500
    },
    setState: () => {}
  }

  let metrics = [
    { id: 42, name: 'Pierogi', systemName: 'pierogi' },
    { id: 666, name: 'Choripanes', systeName: 'choripanes' }
  ]

  let metricsSelector = new StatsMetricsSelector({ statsState: userSelectedState, metrics, container: '#selector' })

  beforeEach(() => {
    document.body.innerHTML = '<div id="selector"></div>'
  })

  it('should render the right selector', () => {
    metricsSelector.render()

    expect(document.querySelector('.StatsSelector-toggle')).toBeTruthy()
    expect(document.querySelector('.StatsSelector-menu')).toBeTruthy()
    expect(document.querySelector('.StatsSelector-toggle').innerHTML).toContain('42.5K Pierogi')
    expect(document.querySelectorAll('.StatsSelector-menu > li')).toHaveLength(2)
  })
})
