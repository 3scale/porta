import { NewMappingRuleWrapper } from 'MappingRules/components/NewMappingRule'
import { safeFromJsonString } from 'utilities/json-utils'

const CONTAINER_ID = 'new-mapping-rule-form'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(CONTAINER_ID)

  if (!container) {
    throw new Error('The target ID was not found: ' + CONTAINER_ID)
  }

  const { url = '', httpMethods, topLevelMetrics, methods, isProxyProEnabled, errors } = container.dataset

  NewMappingRuleWrapper({
    url,
    topLevelMetrics: safeFromJsonString(topLevelMetrics) ?? [],
    methods: safeFromJsonString(methods) ?? [],
    isProxyProEnabled: isProxyProEnabled !== undefined,
    httpMethods: safeFromJsonString<string[]>(httpMethods) ?? [],
    errors: safeFromJsonString(errors)
  }, CONTAINER_ID)
})
