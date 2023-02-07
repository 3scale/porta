import { ChangePlanSelectCardWrapper } from 'Plans/components/ChangePlanSelectCard'
import { safeFromJsonString } from 'utilities/json-utils'

import type { IRecord as Plan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'change_plan_select'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container
  const applicationPlans = safeFromJsonString<Plan[]>(dataset.applicationPlans) ?? []
  const path: string = dataset.path ?? ''

  ChangePlanSelectCardWrapper({
    applicationPlans,
    path
  }, containerId)
})
