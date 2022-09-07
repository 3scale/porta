import { NewAccountsWidgetWrapper } from 'Dashboard/components/NewAccountsWidget'
import { safeFromJsonString } from 'utilities'

const containerId = 'new-accounts-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)
  const { chartData, newAccountsTotal, hasHistory, links, percentualChange } = safeFromJsonString(container.dataset.newAccountsWidget)

  NewAccountsWidgetWrapper({
    chartData,
    newAccountsTotal,
    hasHistory,
    links,
    percentualChange
  }, containerId)
})
