import SwaggerUI from 'swagger-ui'
import { autocompleteOAS3 } from 'ActiveDocs/OAS3Autocomplete'
import 'swagger-ui/dist/swagger-ui.css'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'swagger-ui-container'
  const DATA_URL = 'p/admin/api_docs/account_data.json'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }
  const { url, baseUrl, serviceEndpoint = '' } = container.dataset
  const accountDataUrl = `${baseUrl}${DATA_URL}`

  const responseInterceptor: SwaggerUI.SwaggerUIOptions['responseInterceptor'] = (response) => autocompleteOAS3(response, accountDataUrl, serviceEndpoint)

  SwaggerUI({
    url,
    dom_id: `#${containerId}`,
    responseInterceptor
  })
})
