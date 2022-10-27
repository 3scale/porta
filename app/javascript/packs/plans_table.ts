import { PlansTableCardWrapper } from 'Plans/components/PlansTableCard'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Plans/components/PlansTableCard'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'plans_table'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container
  const { searchHref = '' } = dataset
  const columns = safeFromJsonString<Props['columns']>(dataset.columns) ?? []
  const count = safeFromJsonString<number>(dataset.count) ?? 0
  const plans = safeFromJsonString<Props['plans']>(dataset.plans) ?? []

  PlansTableCardWrapper({
    columns,
    plans,
    count,
    searchHref
  }, containerId)
})
