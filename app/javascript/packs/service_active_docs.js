import { ActiveDocsSpecWrapper as ActiveDocsSpec } from 'ActiveDocs/components/ActiveDocsSpec'
import { fetchData } from 'utilities/utils'

document.addEventListener('DOMContentLoaded', async () => {
  const containerId = 'swagger-ui-container'
  const AUTOCOMPLETE_CONFIG = {
    dataUrl: {
      provider: '/p/admin/api_docs/account_data.json',
      buyer: '/api_docs/account_data.json'
    }
  }
  const { url, baseUrl, accountType } = document.getElementById(containerId).dataset
  const dataUrl = accountType ? AUTOCOMPLETE_CONFIG.dataUrl[accountType] : 'buyer'

  const data = await fetchData(`${baseUrl}${dataUrl}`)
  const accountData = data.status === 200 ? data.results : {}

  ActiveDocsSpec({ url, accountData }, containerId)
})
