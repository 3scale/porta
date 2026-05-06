import SwaggerUI from 'swagger-ui'
import 'swagger-ui/dist/swagger-ui.css'

import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import type { AccountDataResponse } from 'Types/SwaggerTypes'

import 'ActiveDocs/swagger-ui-3-provider-patch.scss'
import { fetchData } from '../src/utilities/fetchData'

const renderActiveDocs = async () => {
  const containerId = 'swagger-ui-container'
  const DATA_URL = 'p/admin/api_docs/account_data.json'
  const container = document.getElementById(containerId)

  if (!container) {
    console.error(`Element with ID ${containerId} not found`)
    return
  }
  const { url = '', baseUrl = '', serviceEndpoint = '' } = container.dataset
  const accountDataUrl = `${baseUrl}${DATA_URL}`

  const accountData: AccountDataResponse = await fetchData<AccountDataResponse>(accountDataUrl)

  const requestInterceptor: SwaggerUI.SwaggerUIOptions['requestInterceptor'] = (request) => autocompleteRequestInterceptor(request, accountData, serviceEndpoint)

  SwaggerUI({
    url,
    domNode: container,
    requestInterceptor
  })
}

document.addEventListener('DOMContentLoaded', () => {
  renderActiveDocs().catch(error => { console.error(error) })
})
