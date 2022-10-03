import { ProductsIndexPageWrapper } from 'Products/components/IndexPage'
import { Product } from 'Products/types'
import { safeFromJsonString } from 'utilities/json-utils'

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
