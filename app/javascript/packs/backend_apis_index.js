import { BackendsIndexPageWrapper } from 'BackendApis/components/IndexPage'
import { safeFromJsonString } from 'utilities'

const containerId = 'backend-apis'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  const { backends, backendsCount } = container.dataset

  BackendsIndexPageWrapper({
    backends: safeFromJsonString(backends),
    backendsCount: safeFromJsonString(backendsCount)
  }, containerId)
})
