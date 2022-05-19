// @flow

import { DefaultPlanSelectWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities'

import type { Record as Plan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('default_plan')

  if (!container) {
    return
  }

  const { dataset } = container
  const plans = safeFromJsonString<Plan[]>(dataset.applicationPlans) || []
  const initialDefaultPlan = safeFromJsonString<Plan>(dataset.currentPlan) || null
  const path: string = dataset.path

  DefaultPlanSelectWrapper({
    initialDefaultPlan,
    plans: plans,
    path
  }, 'default_plan')
})
