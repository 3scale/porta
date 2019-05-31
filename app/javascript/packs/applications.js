import { ApplicationFormWrapper as renderApplicationForm } from 'Applications/ApplicationForm'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const { dataset } = document.getElementById('metadata-form')

  const plans = safeFromJsonString(dataset.plans)
  const defaultPlan = safeFromJsonString(dataset.default_plan)
  const servicePlansAllowed = safeFromJsonString(dataset.servicePlansAllowed)
  const userDefinedFields = safeFromJsonString(dataset.user_defined_fields)

  function setSubmitButtonDisabled (disabled) {
    if (disabled) {
      $('#submit-new-app').attr('disabled', 'disabled')
    } else {
      $('#submit-new-app').removeAttr('disabled')
    }
  }

  const form = document.querySelector('.inputs')

  renderApplicationForm({
    plans,
    defaultPlan,
    userDefinedFields,
    servicePlansAllowed,
    setSubmitButtonDisabled
  }, form)
})
