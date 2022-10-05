import { ProductsWidgetWrapper } from 'Dashboard/components/ProductsWidget'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Dashboard/components/ProductsWidget'

const containerId = 'products-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { newProductPath, productsPath, products } = safeFromJsonString<Props>(container.dataset.productsWidget) as Props

  ProductsWidgetWrapper({
    newProductPath,
    productsPath,
    products
  }, containerId)
})
