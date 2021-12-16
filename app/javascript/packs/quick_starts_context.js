// @flow

import { QuickStartsContextWrapper as QuickStartsContext } from 'QuickStarts/QuickStartsContext'
import '@patternfly/quickstarts/dist/quickstarts.min.css'

const containerId = 'quick-starts-entry'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  QuickStartsContext({}, containerId)
})
