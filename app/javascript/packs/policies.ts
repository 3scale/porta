import { PoliciesWrapper as PoliciesDataList } from 'Policies/components/PoliciesWrapper'
import { safeFromJsonString } from 'utilities/json-utils'

import type { RegistryPolicy, PolicyConfig } from 'Policies/types/Policies'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'policies'
  const policiesContainer = document.getElementById(containerId)

  if (!policiesContainer) {
    throw new Error('Policies Widget needs a valid DOM Element to render')
  }

  const { dataset } = policiesContainer

  const registry = safeFromJsonString<RegistryPolicy[]>(dataset.registry)
  const chain = safeFromJsonString<PolicyConfig[]>(dataset.chain)
  const serviceId = safeFromJsonString<string>(dataset.serviceId)

  if (!registry || !chain || !serviceId) {
    throw new Error('Missing props for policies edit page')
  }

  PoliciesDataList({
    registry,
    chain,
    serviceId
  }, containerId)
})
