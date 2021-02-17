// @flow

import { DefaultPlanSelectWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Product, ApplicationPlan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('default_plan')

  if (!container) {
    return
  }

  const { dataset } = container
  const service = safeFromJsonString<Product>(dataset.service)
  const appPlans = safeFromJsonString<ApplicationPlan[]>(dataset.applicationPlans)
  const initialDefaultPlan = safeFromJsonString<ApplicationPlan>(dataset.currentPlan) || null
  const path: string = dataset.path

  DefaultPlanSelectWrapper({
    initialDefaultPlan,
    product: { ...service, appPlans },
    path
  }, 'default_plan')
})
