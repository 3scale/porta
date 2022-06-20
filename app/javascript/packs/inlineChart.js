import React from 'react'
import { render } from 'react-dom'
import InlineChart from '../src/Stats/inlinechart/index'

document.addEventListener('DOMContentLoaded', () => {
  document
    .getElementById('mini-charts')
    .querySelectorAll('.charts')
    .forEach(chart => {
      const currentChart = chart.querySelector('.inline-chart-container')
      const props = {
        endPoint: currentChart.dataset.endpoint,
        metricName: currentChart.dataset.metricName,
        title: currentChart.dataset.title,
        unitPluralized: chart.dataset.unitPluralized
      }
      render(<InlineChart { ...props } />, currentChart)
    })
})
