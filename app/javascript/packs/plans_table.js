// @flow

import { ApplicationPlansTableCardWrapper } from 'Plans'
import { safeFromJsonString } from 'utilities'

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
