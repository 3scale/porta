/* eslint-disable @typescript-eslint/no-non-null-assertion -- FIXME: we need to give some default values or something */
import * as dashboardWidget from 'Dashboard/ajax-widget'
import { render as renderChartWidget } from 'Dashboard/chart'
import { ProductsWidgetWrapper } from 'Dashboard/components/ProductsWidget'
import { BackendsWidgetWrapper } from 'Dashboard/components/BackendsWidget'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props as ProductsWidgetProps } from 'Dashboard/components/ProductsWidget'
import type { Props as BackendsWidgetProps } from 'Dashboard/components/BackendsWidget'

const productsContainerId = 'products-widget'
const backendsContainerId = 'backends-widget'

document.addEventListener('DOMContentLoaded', () => {
  window.dashboardWidget = dashboardWidget
  window.renderChartWidget = renderChartWidget

  const productsContainer = document.getElementById(productsContainerId)
  const backendsContainer = document.getElementById(backendsContainerId)

  if (!productsContainer) {
    console.error('The target ID was not found: ' + productsContainerId)
  } else {
    const { newProductPath, productsPath, products } = safeFromJsonString<ProductsWidgetProps>(productsContainer.dataset.productsWidget)!

    ProductsWidgetWrapper({
      newProductPath,
      productsPath,
      products
    }, productsContainerId)
  }

  if (!backendsContainer) {
    console.error('The target ID was not found: ' + backendsContainerId)
  } else {
    const { newBackendPath, backendsPath, backends } = safeFromJsonString<BackendsWidgetProps>(backendsContainer.dataset.backendsWidget)!

    BackendsWidgetWrapper({
      newBackendPath,
      backendsPath,
      backends
    }, backendsContainerId)
  }
})
