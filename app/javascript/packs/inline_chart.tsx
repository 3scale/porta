import { render } from 'react-dom'

import { InlineChart } from 'Stats/inlinechart'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'mini-charts'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  function renderChart (chart: HTMLElement) {
    const currentChart = chart.querySelector<HTMLElement>('.inline-chart-container')

    if (!currentChart) {
      throw new Error('Inline chart container not found')
    }

    const { endpoint, metricName, title } = currentChart.dataset
    const { unitPluralized } = chart.dataset

    if (!endpoint || !metricName || !title || !unitPluralized) {
      throw new Error('Missing some props')
    }

    render((
      <InlineChart
        endPoint={endpoint}
        metricName={metricName}
        title={title}
        unitPluralized={unitPluralized}
      />
    ), currentChart)
  }

  container.querySelectorAll<HTMLElement>('.charts')
    .forEach(renderChart)
})
