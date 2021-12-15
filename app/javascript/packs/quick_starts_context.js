// @flow

import { QuickStartsContextWrapper as QuickStartsContext } from 'QuickStarts/QuickStartsContext'
import '@patternfly/quickstarts/dist/quickstarts.min.css'

const containerId = 'qs-entry'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  console.log('rendering qs context')

  QuickStartsContext({}, containerId)
})
