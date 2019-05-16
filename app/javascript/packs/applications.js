import { CreateApplication } from 'Applications/create_application'
import { ApplicationFormWrapper as renderApplicationForm } from 'Applications/ApplicationForm'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const createApplication = new CreateApplication()

  const { dataset } = document.getElementById('metadata-form')
  const plans = safeFromJsonString(dataset.application_plans)

  renderApplicationForm({
    plans,
    onChange: () => createApplication.checkSelectedPlan()
  }, 'cinstance_plan_input')
})
