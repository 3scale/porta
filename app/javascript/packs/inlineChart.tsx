import InlineChart from 'Stats/inlinechart'
import { render } from 'react-dom'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'mini-charts'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const allCharts = container.querySelectorAll<HTMLElement>('.charts')

  function renderChart (chart: HTMLElement) {
    const currentChart = chart.querySelector('.inline-chart-container') as HTMLElement
    const props = {
      endPoint: currentChart.dataset.endpoint as string,
      metricName: currentChart.dataset.metricName as string,
      title: currentChart.dataset.title as string,
      unitPluralized: chart.dataset.unitPluralized as string
    }
    // eslint-disable-next-line react/jsx-props-no-spreading
    render(<InlineChart {...props} />, currentChart)
  }

  allCharts.forEach(chart => {
    renderChart(chart)
  })
})
