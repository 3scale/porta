import { NewPageWrapper as NewPage } from 'Products/components/NewPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Products/components/NewPage'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'new_service_wrapper'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const props = safeFromJsonString<Props>(container.dataset.newService)

  if (!props) {
    return
  }

  NewPage(props, containerId)
})
