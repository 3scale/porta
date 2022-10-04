import { AddBackendFormWrapper } from 'BackendApis/components/AddBackendForm'
import { safeFromJsonString } from 'utilities'

import type { Backend } from 'Types'

const containerId = 'add-backend-form'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { dataset } = container
  const { url = '', backendsPath = '', backendApiId } = dataset

  const backends = safeFromJsonString<Backend[]>(dataset.backends) || []
  const backend = backends.find(b => String(b.id) === backendApiId) || null
  const inlineErrors = safeFromJsonString(dataset.inlineErrors) || null

  AddBackendFormWrapper({
    backends,
    backend,
    inlineErrors,
    url,
    backendsPath
  }, containerId)
})
