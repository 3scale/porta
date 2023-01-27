import { ApiDocsFormWrapper } from 'ActiveDocs/ApiDocsForm'

import type { Props as ApiDocsServiceData } from 'ActiveDocs/ApiDocsForm'

const containerId = 'api-docs-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  const service = JSON.parse(container.dataset.service!) as ApiDocsServiceData

  const { 
    action,
    apiJsonSpec,
    collection, 
    description, 
    errors,
    isUpdate,
    name, 
    published, 
    serviceId, 
    skipSwaggerValidations,
    systemName
  } = service

  ApiDocsFormWrapper({
    action,
    apiJsonSpec,
    collection,
    description,
    errors,
    isUpdate,
    name,
    published,
    serviceId,
    skipSwaggerValidations,
    systemName
  }, containerId)
})
