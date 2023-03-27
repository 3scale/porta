// We can define the 3scale plugins here and export the modified bundle
import SwaggerUI from 'swagger-ui'
import 'swagger-ui/dist/swagger-ui.css'

import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import 'ActiveDocs/swagger-ui-3-patch.scss'

const accountDataUrl = '/api_docs/account_data.json'

window.SwaggerUI = (args: SwaggerUI.SwaggerUIOptions, serviceEndpoint: string) => {
  const requestInterceptor = (request: SwaggerUI.Request) => autocompleteRequestInterceptor(request, accountDataUrl, serviceEndpoint)

  SwaggerUI({
    ...args,
    requestInterceptor
  } as SwaggerUI.SwaggerUIOptions)
}
