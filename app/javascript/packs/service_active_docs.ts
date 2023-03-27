import SwaggerUI from 'swagger-ui'
import 'swagger-ui/dist/swagger-ui.css'

import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import 'ActiveDocs/swagger-ui-3-provider-patch.scss'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'swagger-ui-container'
  const DATA_URL = 'p/admin/api_docs/account_data.json'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }
  const { url = '', baseUrl = '', serviceEndpoint = '' } = container.dataset
  const accountDataUrl = `${baseUrl}${DATA_URL}`

  const requestInterceptor: SwaggerUI.SwaggerUIOptions['requestInterceptor'] = (request) => autocompleteRequestInterceptor(request, accountDataUrl, serviceEndpoint)

  SwaggerUI({
    url,
    // eslint-disable-next-line @typescript-eslint/naming-convention -- SwaggerUI API
    dom_id: `#${containerId}`,
    requestInterceptor
  })
})
