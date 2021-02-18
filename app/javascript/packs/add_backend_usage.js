// @flow

import { AddBackendFormWrapper } from 'BackendApis'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'backend_api_select'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  AddBackendFormWrapper({}, containerId)
})
