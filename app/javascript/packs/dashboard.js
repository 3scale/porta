import * as dashboardWidget from 'Dashboard/ajax-widget'
import { initialize as toggleWidget } from 'Dashboard/toggle'
import { render as renderChartWidget } from 'Dashboard/chart'

document.addEventListener('DOMContentLoaded', () => {
  window.dashboardWidget = dashboardWidget
  window.toggleWidget = toggleWidget
  window.renderChartWidget = renderChartWidget
})
