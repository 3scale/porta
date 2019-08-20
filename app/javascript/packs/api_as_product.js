// TODO: merge this pack into dashboard.js once APIAP rolling updated is removed
import { initialize as tabsWidget } from 'Dashboard/tabs-widget'
import { ApiFilterWrapper as ApiFilter } from 'Dashboard/components/ApiFilter'

import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  tabsWidget()
  void ['products_search', 'backends_search'].forEach(renderApiFilter)
})

function renderApiFilter (id) {
  const { apis, domClass, placeholder } = document.getElementById(id).dataset

  ApiFilter({ apis: safeFromJsonString(apis), domClass, placeholder }, id)
}
