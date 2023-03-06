import SwaggerUI from 'swagger-ui'
import 'swagger-ui/dist/swagger-ui.css'

import { autocompleteOAS3 } from 'ActiveDocs/OAS3Autocomplete'

import 'ActiveDocs/swagger-ui-3-provider-patch.scss'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'swagger-ui-container'
  const DATA_URL = 'p/admin/api_docs/account_data.json'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }
  const { url, baseUrl } = container.dataset
  // eslint-disable-next-line @typescript-eslint/restrict-template-expressions -- FIXME
  const accountDataUrl = `${baseUrl}${DATA_URL}`

  const responseInterceptor: SwaggerUI.SwaggerUIOptions['responseInterceptor'] = (response) => autocompleteOAS3(response, accountDataUrl)

  SwaggerUI({
    url,
    // eslint-disable-next-line @typescript-eslint/naming-convention -- SwaggerUI API
    dom_id: `#${containerId}`,
    responseInterceptor
  })
})
