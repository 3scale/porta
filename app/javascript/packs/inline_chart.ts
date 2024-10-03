import { InlineChartWrapper as InlineChart } from 'Common/components/InlineChart'

import type { Props as InlineChartProps } from 'Common/components/InlineChart'

import './inline_chart.scss'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'mini-charts'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const charts = container.querySelectorAll<HTMLDivElement>('.charts.inlinechart')

  charts.forEach(chart => {
    const chartContainer = chart.querySelector<HTMLElement>('.inline-chart-container')

    if (!chartContainer) {
      throw new Error('Inline chart container not found')
    }

    // Props defined in app/views/stats/_inlinechart.html.erb
    const props = chartContainer.dataset as unknown as InlineChartProps

    InlineChart(props, chartContainer.id)
  })
})
