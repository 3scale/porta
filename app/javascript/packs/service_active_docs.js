import SwaggerUI from 'swagger-ui'
import { autocompleteOAS3 } from './OAS3Autocomplete'
import { proxyOAS3 } from './OAS3Proxy'
import 'swagger-ui/dist/swagger-ui.css'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'swagger-ui-container'
  const DATA_URL = 'p/admin/api_docs/account_data.json'
  const { url, baseUrl, serviceEndpoint, proxyDisabled } = document.getElementById(containerId).dataset
  const accountDataUrl = `${baseUrl}${DATA_URL}`
  const proxyDisabledBoolean = proxyDisabled === 'true'

  const responseInterceptor = (response) => autocompleteOAS3(response, accountDataUrl, serviceEndpoint)
  const requestInterceptor = (request) => proxyOAS3(request, proxyDisabledBoolean)

  SwaggerUI({
    url,
    dom_id: `#${containerId}`,
    responseInterceptor,
    requestInterceptor
  })
})
