// @flow

import { DefaultPlanSelectWrapper } from 'Applications'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Product, ApplicationPlan } from 'Applications/types'

document.addEventListener('DOMContentLoaded', () => {
  // $FlowFixMe
  const { dataset } = document.getElementById('default_plan')
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
