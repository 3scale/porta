import { DefaultPlanSelectCardWrapper } from 'Plans/components/DefaultPlanSelectCard'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Record as Plan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'default_plan'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container
  const plans = safeFromJsonString<Plan[]>(dataset.plans) || []
  const initialDefaultPlan = safeFromJsonString<Plan>(dataset.currentPlan) || null
  const path = dataset.path || ''

  DefaultPlanSelectCardWrapper({
    initialDefaultPlan,
    plans: plans,
    path
  }, containerId)
})
