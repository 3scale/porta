import { NewApplicationFormWrapper } from 'NewApplication'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'new-application-form'

  const { dataset } = document.getElementById(containerId)

  const { createServicePlanPath, createApplicationPath, createApplicationPlanPath } = dataset
  const products = safeFromJsonString(dataset.products)
  const servicePlansAllowed = safeFromJsonString(dataset.servicePlansAllowed)
  const buyer = safeFromJsonString(dataset.buyer)
  const buyers = safeFromJsonString(dataset.buyers)

  NewApplicationFormWrapper({
    createApplicationPath,
    createServicePlanPath,
    createApplicationPlanPath,
    servicePlansAllowed,
    products,
    buyer,
    buyers
  }, containerId)
})
