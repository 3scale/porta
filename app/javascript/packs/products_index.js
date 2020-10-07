import { ProductsIndexPageWrapper } from 'Products/components/IndexPage'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'products'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  const products = safeFromJsonString(container.dataset.products)

  ProductsIndexPageWrapper({
    products
  }, containerId)
})
