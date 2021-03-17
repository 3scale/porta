// @flow

// $FlowIgnore[missing-export] export is there, name_mapper is the problem
import { PlansTableWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities/json-utils'

import type { ApplicationPlan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'plans_table'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const plans = safeFromJsonString<ApplicationPlan[]>(container.dataset.plans) || []

  PlansTableWrapper({
    plans,
    count: 0,
    searchHref: 'apiconfig/services/4/application_plans'
  }, containerId)
})
