import { DefaultPlanSelectWrapper } from 'Applications'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const { dataset } = document.getElementById('default_plan')
  const currentService = safeFromJsonString(dataset.currentService)
  const plans = safeFromJsonString(dataset.applicationPlans)
  const currentPlan = safeFromJsonString(dataset.currentPlan) ?? undefined

  DefaultPlanSelectWrapper({
    currentService,
    plans,
    currentPlan
  }, 'default_plan')
})
