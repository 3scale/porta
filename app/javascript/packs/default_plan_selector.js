import { DefaultPlanSelectorWrapper } from 'Applications'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const { dataset } = document.getElementById('default_plan')
  const plans = safeFromJsonString(dataset.applicationPlans)
  const currentPlanId = Number(dataset.currentPlanId)

  DefaultPlanSelectorWrapper({
    plans,
    currentPlanId
  }, 'default_plan')
})
