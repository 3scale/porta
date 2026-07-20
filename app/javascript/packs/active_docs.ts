// We can define the 3scale plugins here and export the modified bundle
import SwaggerUI from 'swagger-ui'
import 'swagger-ui/dist/swagger-ui.css'

import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'
import { fetchData } from 'utilities/fetchData'

import type { AccountDataResponse } from 'Types/SwaggerTypes'

import 'ActiveDocs/swagger-ui-3-patch.scss'

const accountDataUrl = '/api_docs/account_data.json'

window.SwaggerUI = (args: SwaggerUI.SwaggerUIOptions, serviceEndpoint: string) => {
  fetchData<AccountDataResponse>(accountDataUrl)
    .then(accountData => {
      const requestInterceptor = (request: SwaggerUI.Request) => autocompleteRequestInterceptor(request, accountData, serviceEndpoint)

      return SwaggerUI({
        ...args,
        requestInterceptor
      } as SwaggerUI.SwaggerUIOptions)
    })
    .catch(error => { console.error(error) })
}
