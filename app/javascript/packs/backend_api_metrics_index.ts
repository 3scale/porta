import { BackendAPIIndexPageWrapper } from 'Metrics'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Metric } from 'Types'

const containerId = 'backend-api-metrics-index-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container
  const { addMappingRulePath, createMetricPath, mappingRulesPath } = dataset
  const metrics = safeFromJsonString<Array<Metric>>(dataset.metrics) || []
  const metricsCount = safeFromJsonString<number>(dataset.metricsCount) || metrics.length

  BackendAPIIndexPageWrapper({
    addMappingRulePath,
    createMetricPath,
    mappingRulesPath,
    metrics,
    metricsCount
  }, containerId)
})