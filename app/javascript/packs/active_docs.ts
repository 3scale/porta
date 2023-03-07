// We can define the 3scale plugins here and export the modified bundle
import SwaggerUI from 'swagger-ui'
import 'swagger-ui/dist/swagger-ui.css'

import { autocompleteInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import 'ActiveDocs/swagger-ui-3-patch.scss'

const accountDataUrl = '/api_docs/account_data.json'

window.SwaggerUI = (args: SwaggerUI.SwaggerUIOptions, serviceEndpoint: string) => {
  const responseInterceptor = (response: SwaggerUI.Response) => autocompleteInterceptor(response, args.url, accountDataUrl, serviceEndpoint)

  SwaggerUI({
    ...args,
    responseInterceptor
  } as SwaggerUI.SwaggerUIOptions)
}
