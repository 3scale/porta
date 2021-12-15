// @flow

import { QuickStartsWrapper as QuickStarts } from 'QuickStarts/QuickStarts'
import '@patternfly/quickstarts/dist/quickstarts.min.css'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('qs-drawer')

  if (!container) {
    return
  }

  console.log('rendering qs-drawer')

  QuickStarts({}, 'qs-drawer')
})
