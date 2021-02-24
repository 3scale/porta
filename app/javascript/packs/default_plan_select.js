// @flow

import { DefaultPlanSelectWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities/json-utils'

import type { ApplicationPlan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('default_plan')

  if (!container) {
    return
  }

  const { dataset } = container
  const plans = safeFromJsonString<ApplicationPlan[]>(dataset.applicationPlans)
  const plan = safeFromJsonString<ApplicationPlan>(dataset.currentPlan) || null

  DefaultPlanSelectWrapper({
    plan,
    plans,
    name: 'cinstance[plan_id]',
    placeholderText: 'Select a plan'
  }, 'default_plan')
})
