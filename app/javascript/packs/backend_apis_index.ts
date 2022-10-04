import { BackendsIndexPageWrapper } from 'BackendApis/components/IndexPage'
import { safeFromJsonString } from 'utilities'

import type { Backend } from 'BackendApis/types'

const containerId = 'backend-apis'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { newBackendPath = '', backends, backendsCount } = container.dataset

  BackendsIndexPageWrapper({
    newBackendPath,
    backends: safeFromJsonString<Backend[]>(backends) || [],
    backendsCount: safeFromJsonString<number>(backendsCount) || 0
  }, containerId)
})
