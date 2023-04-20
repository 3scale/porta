// We can define the 3scale plugins here and export the modified bundle
import 'swagger-ui/dist/swagger-ui.css'

import { renderSwaggerUI } from 'ActiveDocs/ThreeScaleApiDocs'

import 'ActiveDocs/swagger-ui-3-provider-patch.scss'

const renderActiveDocs = async () => {
  const containerId = 'api-containers'
  const container = document.getElementById(containerId)

  if (!container) {
    console.error(`The target element with ID ${containerId} was not found`)
    return
  }

  const { baseUrl = '', apiDocsPath = '', apiDocsAccountDataPath = '' } = container.dataset

  await renderSwaggerUI(container, apiDocsPath, baseUrl, apiDocsAccountDataPath)
}

document.addEventListener('DOMContentLoaded', () => {
  renderActiveDocs().catch(error => { console.error(error) })
})
