import { widget as dashboardWidget } from 'Dashboard/index'
import { initialize as toggleWidget } from 'Dashboard/toggle'
import { render as renderChartWidget } from 'Dashboard/chart'
import { ApiFilterWrapper } from 'Dashboard/components/ApiFilter'

document.addEventListener('DOMContentLoaded', () => {
  window.dashboardWidget = dashboardWidget
  window.toggleWidget = toggleWidget
  window.renderChartWidget = renderChartWidget
  window.ApiFilter = ApiFilterWrapper
})
