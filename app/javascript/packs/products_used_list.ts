import { ProductsUsedListCardWrapper } from 'BackendApis/components/ProductsUsedListCard'
import { safeFromJsonString } from 'utilities/json-utils'

import type { CompactListItem } from 'Common/components/CompactListCard'

const containerId = 'products-used-list-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { products } = container.dataset

  ProductsUsedListCardWrapper({
    products: safeFromJsonString<Array<CompactListItem>>(products) || []
  }, containerId)
})
