// We can define the 3scale plugins here and export the modified bundle
import SwaggerUI from 'swagger-ui'
import { autocompleteOAS3, proxyOAS3 } from 'ActiveDocs'
import 'swagger-ui/dist/swagger-ui.css'
import 'ActiveDocs/swagger-ui-3-patch.scss'

const accountDataUrl = '/api_docs/account_data.json'

window.SwaggerUI = (args, serviceEndpoint) => {
  const responseInterceptor = (response) => autocompleteOAS3(response, accountDataUrl, serviceEndpoint)
  const requestInterceptor = (request) => proxyOAS3(request)

  SwaggerUI({
    ...args,
    responseInterceptor,
    requestInterceptor
  })
}
