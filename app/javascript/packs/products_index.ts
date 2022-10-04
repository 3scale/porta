import { ProductsIndexPageWrapper } from 'Products/components/IndexPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Product } from 'Products/types'

const containerId = 'products'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { newProductPath = '', products, productsCount } = container.dataset

  ProductsIndexPageWrapper({
    newProductPath,
    products: safeFromJsonString<Product[]>(products) || [],
    productsCount: safeFromJsonString<number>(productsCount) || 0
  }, containerId)
})
