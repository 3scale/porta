import { ActiveDocsSpecWrapper as ActiveDocsSpec } from 'ActiveDocs/components/ActiveDocsSpec'
import { autocompleteOAS3 } from './OAS3Autocomplete'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'swagger-ui-container'
  const DATA_URL = 'p/admin/api_docs/account_data.json'
  const { url, baseUrl } = document.getElementById(containerId).dataset
  const accountDataUrl = `${baseUrl}${DATA_URL}`

  const responseInterceptor = (response) => autocompleteOAS3(response, accountDataUrl)

  ActiveDocsSpec({ url, responseInterceptor }, containerId)
})
