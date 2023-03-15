// We can define the 3scale plugins here and export the modified bundle
import 'swagger-ui/dist/swagger-ui.css'

import { renderApiDocs } from 'ActiveDocs/ThreeScaleApiDocs'

import 'ActiveDocs/swagger-ui-3-provider-patch.scss'

// eslint-disable-next-line @typescript-eslint/no-misused-promises
document.addEventListener('DOMContentLoaded', async () => {
  const containerId = 'api-containers'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { baseUrl = '', apiDocsPath = '', apiDocsAccountDataPath = '' } = container.dataset

  await renderApiDocs(container, apiDocsPath, baseUrl, apiDocsAccountDataPath)
})
