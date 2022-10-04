/* eslint-disable react/jsx-props-no-spreading */
import InlineChart from '../src/Stats/inlinechart/index'

import { render } from 'react-dom'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('mini-charts')
  const allCharts = [...container.querySelectorAll('.charts')]

  function renderChart (chart) {
    const currentChart = chart.querySelector('.inline-chart-container')
    const props = {
      endPoint: currentChart.dataset.endpoint,
      metricName: currentChart.dataset.metricName,
      title: currentChart.dataset.title,
      unitPluralized: chart.dataset.unitPluralized
    }
    render(<InlineChart {...props} />, currentChart)
  }

  allCharts.forEach(chart => {
    renderChart(chart)
  })
})
