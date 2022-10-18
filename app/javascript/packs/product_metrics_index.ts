import { ProductIndexPageWrapper } from 'Metrics/components/ProductIndexPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Metric } from 'Types'

const containerId = 'product-metrics-index-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container
  const { applicationPlansPath = '', addMappingRulePath = '', createMetricPath = '', mappingRulesPath = '' } = dataset
  const metrics = safeFromJsonString<Metric[]>(dataset.metrics) || []
  const metricsCount = safeFromJsonString<number>(dataset.metricsCount) || metrics.length

  ProductIndexPageWrapper({
    applicationPlansPath,
    addMappingRulePath,
    createMetricPath,
    mappingRulesPath,
    metrics,
    metricsCount
  }, containerId)
})
