// @flow

import { NewMappingRuleWrapper } from 'MappingRules'
import { safeFromJsonString } from 'utilities/json-utils'

const CONTAINER_ID = 'new-mapping-rule-form'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(CONTAINER_ID)

  if (!container) {
    return
  }

  const { url, httpMethods, metrics, isProxyProEnabled } = container.dataset

  const { topLevelMetrics = [], methods = [] } = safeFromJsonString(metrics) || {}

  NewMappingRuleWrapper({
    url,
    topLevelMetrics,
    methods,
    isProxyProEnabled: safeFromJsonString<boolean>(isProxyProEnabled),
    httpMethods: safeFromJsonString<Array<string>>(httpMethods) || []
  }, CONTAINER_ID)
})
