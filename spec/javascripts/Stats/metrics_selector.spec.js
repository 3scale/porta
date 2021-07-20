import $ from 'jquery'

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
    {id: 42, name: 'Pierogi', systemName: 'pierogi'},
    {id: 666, name: 'Choripanes', systeName: 'choripanes'}
  ]

  let metricsSelector = new StatsMetricsSelector({statsState: userSelectedState, metrics, container: '#selector'})

  beforeEach(() => {
    document.body.innerHTML = '<div id="selector"></div>'
  })

  it('should render the right selector', () => {
    metricsSelector.render()

    expect($('.StatsSelector-toggle')).toBeTruthy()
    expect($('.StatsSelector-menu')).toBeTruthy()
    expect($('.StatsSelector-toggle').text()).toContain('42.5K Pierogi')
    expect($('.StatsSelector-menu > li')).toHaveLength(2)
  })
})
