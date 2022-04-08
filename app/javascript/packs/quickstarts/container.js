// @flow

import { QuickStartContainerWrapper as QuickStartContainer } from 'QuickStarts/components/QuickStartContainer'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'quick-start-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error(`Container not found: #${containerId}`)
  }

  const { links, renderCatalog } = container.dataset

  QuickStartContainer({
    links: safeFromJsonString<Array<[string, string, string]>>(links) || [],
    renderCatalog: safeFromJsonString<boolean>(renderCatalog)
  }, containerId)
})
