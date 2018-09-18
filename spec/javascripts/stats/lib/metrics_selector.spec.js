import $ from 'jquery'

import { StatsMetricsSelector } from 'stats/lib/metrics_selector'

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
    fixture.set('<div id="selector"></div>')
  })

  it('should render the right selector', () => {
    metricsSelector.render()

    expect($('.StatsSelector-toggle')).toBeInDOM()
    expect($('.StatsSelector-menu')).toBeInDOM()
    expect($('.StatsSelector-toggle')).toContainHtml('42.5K Pierogi')
    expect($('.StatsSelector-menu > li')).toHaveLength(2)
  })
})
