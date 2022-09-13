import { PoliciesWrapper as PoliciesWidget } from 'Policies'

document.addEventListener('DOMContentLoaded', () => {
  const policiesContainer = document.getElementById('policies')

  if (!policiesContainer) {
    throw new Error('Policies Widget needs a valid DOM Element to render')
  }

  const { registry, chain, serviceId } = policiesContainer.dataset

  PoliciesWidget({
    registry: JSON.parse(registry),
    chain: JSON.parse(chain),
    serviceId: JSON.parse(serviceId)
  }, 'policies')
})
