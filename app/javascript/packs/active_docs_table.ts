import { IndexTableWrapper as IndexTable } from 'ActiveDocs/components/IndexTable'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'ActiveDocs/components/IndexTable'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'active-docs-table-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error(`Missing container with id "${containerId}"`)
  }

  const props = safeFromJsonString<Props>(container.dataset.props)

  if (!props) {
    throw new Error('Missing table props')
  }

  IndexTable(props, containerId)
})
