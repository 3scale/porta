import { ApplicationFormWrapper as renderApplicationForm } from 'Applications/ApplicationForm'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const { dataset } = document.getElementById('metadata-form')

  const plans = safeFromJsonString(dataset.application_plans)
  const servicesContracted = safeFromJsonString(dataset.services_contracted)
  const relationServiceAndServicePlans = safeFromJsonString(dataset.relation_service_and_service_plans)
  const relationPlansServices = safeFromJsonString(dataset.relation_plans_services)
  const servicePlanContractedForService = safeFromJsonString(dataset.service_plan_contracted_for_service)

  renderApplicationForm({
    plans,
    servicesContracted,
    relationServiceAndServicePlans,
    relationPlansServices,
    servicePlanContractedForService
  }, 'cinstance_plan_input')
})
