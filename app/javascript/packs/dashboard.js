import { widget as dashboardWidget } from '../src/Dashboard/index'
import { initialize as toggleWidget } from '../src/Dashboard/toggle'
import { render as renderChartWidget } from '../src/Dashboard/chart'
import { ApiFilterWrapper } from '../src/Dashboard/components/ApiFilter'

document.addEventListener('DOMContentLoaded', () => {
  window.dashboardWidget = dashboardWidget
  window.toggleWidget = toggleWidget
  window.renderChartWidget = renderChartWidget
  window.ApiFilter = ApiFilterWrapper
})
