import { NewApplicationFormWrapper } from 'Applications'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'new-application-form'

  const { dataset } = document.getElementById(containerId)

  const { createServicePlanPath, createApplicationPath, buyerId, createApplicationPlanPath } = dataset
  const products = safeFromJsonString(dataset.services)
  const applicationPlans = safeFromJsonString(dataset.applicationPlans)
  const servicePlansAllowed = safeFromJsonString(dataset.servicePlansAllowed)
  // Needed?
  // const relationServiceAndServicePlans = safeFromJsonString(dataset.relationServiceAndServicePlans)
  // const relationPlansServices = safeFromJsonString(dataset.relationPlansServices)
  const servicesContracted = safeFromJsonString(dataset.servicesContracted)
  const servicePlanContractedForService = safeFromJsonString(dataset.servicePlanContractedForService)

  NewApplicationFormWrapper({
    createServicePlanPath,
    createApplicationPath,
    createApplicationPlanPath,
    buyerId,
    products,
    applicationPlans,
    servicePlansAllowed,
    // relationServiceAndServicePlans,
    // relationPlansServices,
    servicesContracted,
    servicePlanContractedForService
  }, containerId)
})
