// @flow

import { QuickStartContainerWrapper as QuickStartContainer } from 'QuickStarts/components/QuickStartContainer'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'quick-start-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error(`Container not found: #${containerId}`)
  }

  const { renderCatalog } = container.dataset

  QuickStartContainer({
    renderCatalog: safeFromJsonString<boolean>(renderCatalog)
  }, containerId)
})
