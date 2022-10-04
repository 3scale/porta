import { DefaultPlanSelectCardWrapper } from 'Plans/components/DefaultPlanSelectCard'
import { safeFromJsonString } from 'utilities'

import type { Record as Plan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'default_plan'
  const container = document.getElementById(containerId)

  if (!container) {
    return
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
