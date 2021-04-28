// @flow

import { ProductsUsedTableWrapper } from 'BackendApis'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'products_using_backend'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { products } = container.dataset

  ProductsUsedTableWrapper({
    products: safeFromJsonString(products) || []
  }, containerId)
})
