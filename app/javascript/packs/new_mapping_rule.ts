import {NewMappingRuleWrapper} from 'MappingRules';
import { safeFromJsonString } from 'utilities'

const CONTAINER_ID = 'new-mapping-rule-form'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(CONTAINER_ID)

  if (!container) {
    return
  }

  const { url, httpMethods, topLevelMetrics, methods, isProxyProEnabled, errors } = container.dataset

  NewMappingRuleWrapper({
    url,
    topLevelMetrics: safeFromJsonString(topLevelMetrics) || [],
    methods: safeFromJsonString(methods) || [],
    isProxyProEnabled: isProxyProEnabled !== undefined,
    httpMethods: safeFromJsonString<Array<string>>(httpMethods) || [],
    errors: safeFromJsonString(errors)
  }, CONTAINER_ID)
})
