// @flow

import { BackendIndexPageWrapper } from 'Metrics'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'backend-metrics-index-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { mappingRulesPath } = container.dataset
  console.log(container.dataset, safeFromJsonString)

  BackendIndexPageWrapper({
    mappingRulesPath
  }, containerId)
})
