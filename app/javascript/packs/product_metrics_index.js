// @flow

import { ProductIndexPageWrapper } from 'Metrics'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'product-metrics-index-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { applicationPlansPath, mappingRulesPath } = container.dataset
  console.log(container.dataset, safeFromJsonString)

  ProductIndexPageWrapper({
    applicationPlansPath,
    mappingRulesPath
  }, containerId)
})
