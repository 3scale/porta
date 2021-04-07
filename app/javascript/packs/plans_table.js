// @flow

// $FlowIgnore[missing-export] export is there, name_mapper is the problem
import { ApplicationPlansTableCardWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities/json-utils'

import type { ApplicationPlan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'plans_table'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { searchHref } = container.dataset
  const count = safeFromJsonString<number>(container.dataset.count) || 0
  const plans = safeFromJsonString<ApplicationPlan[]>(container.dataset.plans) || []

  ApplicationPlansTableCardWrapper({
    plans,
    count,
    searchHref
  }, containerId)
})
