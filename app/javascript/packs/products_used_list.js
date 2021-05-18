// @flow

import { ProductsUsedListCardWrapper } from 'BackendApis'
import { safeFromJsonString } from 'utilities'

import type { CompactListItem } from 'Common'

const containerId = 'products-used-list-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { products } = container.dataset

  ProductsUsedListCardWrapper({
    products: safeFromJsonString<Array<CompactListItem>>(products) || []
  }, containerId)
})
