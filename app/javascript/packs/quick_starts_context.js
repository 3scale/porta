// @flow

import { QuickStartsContextWrapper as QuickStartsContext } from 'QuickStarts/QuickStartsContext'
// some global styles and variables that quickstarts uses (Drawer, Popover, Modal, Backdrop, Bullseye)
import '@patternfly/quickstarts/dist/patternfly-global.css'
// PF and quickstarts styles nested within .pfext-quick-start__base
import '@patternfly/quickstarts/dist/patternfly-nested.css'
import '@patternfly/quickstarts/dist/quickstarts-standalone.css'

const containerId = 'quick-starts-entry'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  QuickStartsContext({}, containerId)
})
