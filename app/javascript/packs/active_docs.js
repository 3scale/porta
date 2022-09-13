// We can define the 3scale plugins here and export the modified bundle
import SwaggerUI from 'swagger-ui'
import { autocompleteOAS3 } from 'ActiveDocs/OAS3Autocomplete'
import 'swagger-ui/dist/swagger-ui.css'
import 'ActiveDocs/swagger-ui-3-patch.scss'

const accountDataUrl = '/api_docs/account_data.json'

window.SwaggerUI = (args, serviceEndpoint) => {
  const responseInterceptor = (response) => autocompleteOAS3(response, accountDataUrl, serviceEndpoint)

  SwaggerUI({
    ...args,
    responseInterceptor
  })
}
