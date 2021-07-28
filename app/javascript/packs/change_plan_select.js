// @flow

import { ChangePlanSelectCardWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities'

import type { Product, Plan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'change_plan_select'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { dataset } = container
  // $FlowIgnore[incompatible-cast] we can safely assume service is not undefined
  const service = (safeFromJsonString<Product>(dataset.service): Product)
  const appPlans = safeFromJsonString<Plan[]>(dataset.applicationPlans) || []
  const initialSelectedPlan = safeFromJsonString<Plan>(dataset.currentPlan) || null
  const path: string = dataset.path

  ChangePlanSelectCardWrapper({
    initialSelectedPlan,
    product: { ...service, appPlans },
    path
  }, containerId)
})
