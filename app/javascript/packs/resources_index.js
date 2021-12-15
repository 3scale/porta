// @flow

import { ResourcesWrapper as Resources } from 'QuickStarts/Resources'
import '@patternfly/quickstarts/dist/quickstarts.min.css'

const containerId = 'resources'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  Resources({}, containerId)
})
