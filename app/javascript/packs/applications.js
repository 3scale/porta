import { ApplicationFormWrapper as renderApplicationForm } from 'Applications/ApplicationForm'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  // Remove formtastic forms
  document.getElementById('cinstance_service_plan_id_input').remove()
  document.getElementById('cinstance_plan_input').remove()

  const form = document.querySelector('.inputs > ol')
  const tempDiv = document.createElement('div')
  form.prepend(tempDiv)

  const { dataset } = document.getElementById('metadata-form')

  const plans = safeFromJsonString(dataset.application_plans)
  const servicesContracted = safeFromJsonString(dataset.services_contracted)
  const relationServiceAndServicePlans = safeFromJsonString(dataset.relation_service_and_service_plans)
  const relationPlansServices = safeFromJsonString(dataset.relation_plans_services)
  const servicePlanContractedForService = safeFromJsonString(dataset.service_plan_contracted_for_service)
  const servicePlansAllowed = safeFromJsonString(dataset.service_plans_allowed)

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
    servicePlansAllowed
  }, tempDiv)

  form.prepend(document.getElementById('cinstance_service_plan_id_input'))
  form.prepend(document.getElementById('cinstance_plan_input'))
  tempDiv.remove()
})
