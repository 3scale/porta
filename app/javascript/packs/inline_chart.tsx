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
    const currentChart = chart.querySelector<HTMLElement>('.inline-chart-container')
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- TODO: need to give some default values or something here
    const { endpoint, metricName, title, unitPluralized } = currentChart!.dataset
    render((
      <InlineChart
        endPoint={endpoint as unknown as string}
        metricName={metricName as unknown as string}
        title={title as unknown as string}
        unitPluralized={unitPluralized as unknown as string}
      />
    ), currentChart)
  }

  allCharts.forEach(chart => {
    renderChart(chart)
  })
})
