// @flow

import { AddBackendFormWrapper } from 'BackendApis'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'add-backend-form'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { backends, url, newBackendPath } = container.dataset

  AddBackendFormWrapper({
    backends: safeFromJsonString(backends) || [],
    url,
    newBackendPath
  }, containerId)
})
