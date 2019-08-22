// TODO: remove this pack when apiap rolling updated is removed
import { ApiFilterWrapper as ApiFilter } from 'Dashboard/components/ApiFilter'

import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const id = 'api_filter'
  const { apis, domClass } = document.getElementById(id).dataset

  ApiFilter({ apis: safeFromJsonString(apis), domClass }, id)
})
