// @flow

import { ChangePlanSelectCardWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities'

import type { Plan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'change_plan_select'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { dataset } = container
  const applicationPlans = safeFromJsonString<Plan[]>(dataset.applicationPlans) || []
  const path: string = dataset.path

  ChangePlanSelectCardWrapper({
    applicationPlans,
    path
  }, containerId)
})
