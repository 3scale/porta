import { BackendsWidgetWrapper } from 'Dashboard/components/BackendsWidget'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Dashboard/components/BackendsWidget'

const containerId = 'backends-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: we need some default values or something
  const { newBackendPath, backendsPath, backends } = safeFromJsonString<Props>(container.dataset.backendsWidget)!

  BackendsWidgetWrapper({
    newBackendPath,
    backendsPath,
    backends
  }, containerId)
})
