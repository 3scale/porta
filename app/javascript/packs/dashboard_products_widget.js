import { ProductsWidgetWrapper } from 'Dashboard/components/ProductsWidget'
import { safeFromJsonString } from 'utilities'

const containerId = 'products-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  const { newProductPath, productsPath, products } = safeFromJsonString(container.dataset.productsWidget)

  ProductsWidgetWrapper({
    newProductPath,
    productsPath,
    products
  }, containerId)
})
