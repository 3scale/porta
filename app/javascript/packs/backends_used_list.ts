import { BackendsUsedListCardWrapper } from 'Products/components/BackendsUsedListCard'
import { safeFromJsonString } from 'utilities/json-utils'

import type { CompactListItem } from 'Common/components/CompactListCard'

const containerId = 'backends-used-list-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { backends } = container.dataset

  BackendsUsedListCardWrapper({
    backends: safeFromJsonString<Array<CompactListItem>>(backends) || []
  }, containerId)
})
