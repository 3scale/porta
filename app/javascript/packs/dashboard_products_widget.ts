import { ProductsWidgetWrapper } from 'Dashboard/components/ProductsWidget'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Dashboard/components/ProductsWidget'

const containerId = 'products-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: we need to give some default values or something
  const { newProductPath, productsPath, products } = safeFromJsonString<Props>(container.dataset.productsWidget)!

  ProductsWidgetWrapper({
    newProductPath,
    productsPath,
    products
  }, containerId)
})
