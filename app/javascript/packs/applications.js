import { ApplicationFormWrapper as renderApplicationForm } from 'Applications/ApplicationForm'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('.inputs')

  const { dataset } = document.getElementById('metadata-form')

  const plans = safeFromJsonString(dataset.application_plans)
  const servicesContracted = safeFromJsonString(dataset.services_contracted)
  const relationServiceAndServicePlans = safeFromJsonString(dataset.relation_service_and_service_plans)
  const relationPlansServices = safeFromJsonString(dataset.relation_plans_services)
  const servicePlanContractedForService = safeFromJsonString(dataset.service_plan_contracted_for_service)
  const servicePlansAllowed = safeFromJsonString(dataset.service_plans_allowed)
  const userDefinedFields = safeFromJsonString(dataset.user_defined_fields)

  function setSubmitButtonDisabled (disabled) {
    if (disabled) {
      $('#submit-new-app').attr('disabled', 'disabled')
    } else {
      $('#submit-new-app').removeAttr('disabled')
    }
  }

  renderApplicationForm({
    plans,
    servicesContracted,
    relationServiceAndServicePlans,
    relationPlansServices,
    servicePlanContractedForService,
    setSubmitButtonDisabled,
    userDefinedFields,
    servicePlansAllowed
  }, form)
})
