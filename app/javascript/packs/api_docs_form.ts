import { ApiDocsFormWrapper } from 'ActiveDocs/ApiDocsForm'
import { safeFromJsonString } from 'utilities/json-utils'

import type { IRecord as Service } from 'Types'

interface ApiDocsService {
  name: string;
  published: boolean;
  description: string;
  serviceId?: number;
  collection?: Service[];
  systemName: string;
  body: string;
  skipSwaggerValidations: boolean;
  errors: {
    name?: string[];
    body?: string[];
    systemName?: string[];
  };
  url: string;
}

const containerId = 'api-docs-container'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container

  const service = safeFromJsonString<ApiDocsService>(dataset.service) ?? {} as ApiDocsService

  const { 
    name, 
    published, 
    systemName,
    description, 
    serviceId, 
    collection, 
    body,
    errors,
    skipSwaggerValidations,
    url
  } = service

  console.log({ service })

  ApiDocsFormWrapper({
    name,
    systemName,
    errors,
    published,
    description,
    serviceId,
    collection,
    apiJsonSpec: body,
    skipSwaggerValidations,
    url
  }, containerId)
})
