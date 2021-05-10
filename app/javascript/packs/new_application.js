// @flow

// $FlowIgnore[missing-export] it is exported but name-mapper is failing
import { NewApplicationFormWrapper } from 'NewApplication'
import { safeFromJsonString } from 'utilities'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'new-application-form'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { dataset } = container

  const { createServicePlanPath, createApplicationPath, createApplicationPlanPath, serviceSubscriptionsPath } = dataset
  const product = safeFromJsonString(dataset.product)
  const products = safeFromJsonString(dataset.products)
  const servicePlansAllowed = safeFromJsonString(dataset.servicePlansAllowed)
  const buyer = safeFromJsonString(dataset.buyer)
  const buyers = safeFromJsonString(dataset.buyers)
  const definedFields = safeFromJsonString(dataset.definedFields)
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
    buyer,
    buyers,
    definedFields,
    validationErrors,
    error
  }, containerId)
})
