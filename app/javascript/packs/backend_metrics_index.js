// @flow

import { BackendIndexPageWrapper } from 'Metrics'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Metric } from 'Types'

const containerId = 'backend-metrics-index-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container
  const { applicationPlansPath, createMetricPath, mappingRulesPath } = dataset
  const metrics = safeFromJsonString<Array<Metric>>(dataset.metrics) || []
  const metricsCount = safeFromJsonString<number>(dataset.metricsCount) || metrics.length

  console.log(metrics, dataset)

  BackendIndexPageWrapper({
    applicationPlansPath,
    createMetricPath,
    mappingRulesPath,
    metrics,
    metricsCount
  }, containerId)
})
