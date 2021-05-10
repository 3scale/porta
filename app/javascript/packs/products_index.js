import { ProductsIndexPageWrapper } from 'Products/components/IndexPage'
import { safeFromJsonString } from 'utilities'

const containerId = 'products'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  const { products, productsCount } = container.dataset

  ProductsIndexPageWrapper({
    products: safeFromJsonString(products),
    productsCount: safeFromJsonString(productsCount)
  }, containerId)
})
