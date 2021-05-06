// @flow

import { ProductsUsedListWrapper } from 'BackendApis'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'products-used-list-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { products } = container.dataset

  ProductsUsedListWrapper({
    products: safeFromJsonString(products) || []
  }, containerId)
})
