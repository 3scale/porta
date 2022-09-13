import { BackendsUsedListCardWrapper } from 'Products'
import { safeFromJsonString } from 'utilities'

import type { CompactListItem } from 'Common'

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
