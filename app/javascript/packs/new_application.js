// @flow

import { NewApplicationFormWrapper } from 'NewApplication'
import { safeFromJsonString } from 'utilities'

import type { Buyer, Product } from 'NewApplication/types'
import type { FieldDefinition } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'new-application-form'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { dataset } = container

  const {
    buyersPath,
    productsPath,
    createServicePlanPath,
    createApplicationPath,
    createApplicationPlanPath,
    serviceSubscriptionsPath
  } = dataset
  const product = safeFromJsonString<Product>(dataset.product)
  const products = safeFromJsonString<Product[]>(dataset.mostRecentlyUpdatedProducts)
  const productsCount = safeFromJsonString<number>(dataset.productsCount)
  const servicePlansAllowed = safeFromJsonString<boolean>(dataset.servicePlansAllowed)
  const buyer = safeFromJsonString<Buyer>(dataset.buyer)
  const buyers = safeFromJsonString<Buyer[]>(dataset.mostRecentlyCreatedBuyers)
  const buyersCount = safeFromJsonString<number>(dataset.buyersCount)
  const definedFields = safeFromJsonString<FieldDefinition[]>(dataset.definedFields)
  const validationErrors = safeFromJsonString(dataset.errors) || {}
  const error: string | void = validationErrors.hasOwnProperty('base') ? validationErrors.base[0] : undefined

  NewApplicationFormWrapper({
    createApplicationPath,
    createServicePlanPath,
    createApplicationPlanPath,
    serviceSubscriptionsPath,
    servicePlansAllowed,
    product,
    products,
    productsCount,
    productsPath,
    buyer,
    buyers,
    buyersCount,
    buyersPath,
    definedFields,
    validationErrors,
    error
  }, containerId)
})
