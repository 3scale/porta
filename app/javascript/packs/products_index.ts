import {ProductsIndexPageWrapper} from 'Products';
import { safeFromJsonString } from 'utilities'

import type { Product } from 'Products/types'

const containerId = 'products'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { newProductPath, products, productsCount } = container.dataset

  ProductsIndexPageWrapper({
    newProductPath,
    products: safeFromJsonString<Product[]>(products) || [],
    productsCount: safeFromJsonString<number>(productsCount) || 0
  }, containerId)
})
