import { widget as renderWidget } from 'Dashboard'
import { ProductsWidgetWrapper } from 'Dashboard/components/ProductsWidget'
import { BackendsWidgetWrapper } from 'Dashboard/components/BackendsWidget'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props as ProductsWidgetProps } from 'Dashboard/components/ProductsWidget'
import type { Props as BackendsWidgetProps } from 'Dashboard/components/BackendsWidget'

const newAccountsContainerId = 'new-accounts-widget'
const potentialUpgradesContainerId = 'potential-upgrades-widget'
const productsContainerId = 'products-widget'
const backendsContainerId = 'backends-widget'

document.addEventListener('DOMContentLoaded', () => {
  const newAccountsContainer = document.getElementById(newAccountsContainerId)
  const potentialUpgradesContainer = document.getElementById(potentialUpgradesContainerId)

  if (newAccountsContainer) {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- path should be there
    renderWidget(newAccountsContainer.dataset.path!)
  }

  if (potentialUpgradesContainer) {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- path should be there
    renderWidget(potentialUpgradesContainer.dataset.path!)
  }

  const productsContainer = document.getElementById(productsContainerId)
  const backendsContainer = document.getElementById(backendsContainerId)

  if (productsContainer) {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: handle undefined or use JSON.parse
    const { newProductPath, productsPath, products } = safeFromJsonString<ProductsWidgetProps>(productsContainer.dataset.productsWidget)!

    ProductsWidgetWrapper({
      newProductPath,
      productsPath,
      products
    }, productsContainerId)
  }

  if (backendsContainer) {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: handle undefined or use JSON.parse
    const { newBackendPath, backendsPath, backends } = safeFromJsonString<BackendsWidgetProps>(backendsContainer.dataset.backendsWidget)!

    BackendsWidgetWrapper({
      newBackendPath,
      backendsPath,
      backends
    }, backendsContainerId)
  }
})
