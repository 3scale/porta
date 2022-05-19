// @flow

import { PlansTableCardWrapper } from 'Plans/components/PlansTableCard'
import { safeFromJsonString } from 'utilities'

import type { Plan } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'plans_table'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { dataset } = container
  const { searchHref } = dataset
  const columns = safeFromJsonString<Array<{ attribute: string, title: string }>>(dataset.columns) || []
  const count = safeFromJsonString<number>(dataset.count) || 0
  const plans = safeFromJsonString<Plan[]>(dataset.plans) || []

  PlansTableCardWrapper({
    columns,
    plans,
    count,
    searchHref
  }, containerId)
})
