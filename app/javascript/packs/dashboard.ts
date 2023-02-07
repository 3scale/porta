import * as dashboardWidget from 'Dashboard/ajax-widget'
import { render as renderChartWidget } from 'Dashboard/chart'

document.addEventListener('DOMContentLoaded', () => {
  window.dashboardWidget = dashboardWidget
  window.renderChartWidget = renderChartWidget
})
