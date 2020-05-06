import { ActiveDocsSpecWrapper as ActiveDocsSpec } from 'ActiveDocs/components/ActiveDocsSpec'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'swagger-ui-container'
  const { url, service } = document.getElementById(containerId).dataset

  ActiveDocsSpec({ url, service }, containerId)
})
