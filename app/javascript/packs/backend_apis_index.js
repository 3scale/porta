import { BackendsIndexPageWrapper } from 'BackendApis/components/IndexPage'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'backend-apis'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  const backends = safeFromJsonString(container.dataset.backends)

  BackendsIndexPageWrapper({
    backends
  }, containerId)
})
