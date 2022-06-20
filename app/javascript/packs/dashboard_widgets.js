import * as dashboardWidget from 'Dashboard/ajax-widget'
import { render as renderChartWidget } from 'Dashboard/chart'

document.addEventListener('DOMContentLoaded', () => {
  window.renderChartWidget = renderChartWidget

  dashboardWidget.loadAudienceWidget('/p/admin/dashboard/new_accounts')
  dashboardWidget.loadAudienceWidget('/p/admin/dashboard/potential_upgrades')
})
