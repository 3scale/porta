import { ApiDocsFormWrapper } from 'ActiveDocs/ApiDocsForm'
import { safeFromJsonString } from 'utilities/json-utils'

// import type { Backend } from 'Types'

const containerId = 'api-docs-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container
  // const { url = '', backendsPath = '', backendApiId } = dataset

  // const backends = safeFromJsonString<Backend[]>(dataset.backends) ?? []
  // const backend = backends.find(b => String(b.id) === backendApiId) ?? null
  // const inlineErrors = safeFromJsonString(dataset.inlineErrors) || null

  ApiDocsFormWrapper({
      name,
      systemName,
      publish,
      description,
      apiJsonSpec
  }, containerId)
})
