import { safeFromJsonString } from 'utilities/json-utils'
import { NewAccountsWidgetWrapper } from 'Dashboard/components/NewAccountsWidget'

import type { Props } from 'Dashboard/components/NewAccountsWidget'

const containerId = 'new-accounts-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { chartData, newAccountsTotal, hasHistory, links, percentualChange } = safeFromJsonString<Props>(container.dataset.newAccountsWidget) ?? {}

  NewAccountsWidgetWrapper({
    chartData,
    newAccountsTotal,
    hasHistory,
    links,
    percentualChange
  }, containerId)
})
