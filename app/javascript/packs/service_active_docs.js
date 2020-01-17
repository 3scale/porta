import { ActiveDocsSpecWrapper as ActiveDocsSpec } from 'ActiveDocs/components/Spec'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'swagger-ui-container'
  const { url } = document.getElementById(containerId).dataset

  ActiveDocsSpec({ url }, containerId)
})
