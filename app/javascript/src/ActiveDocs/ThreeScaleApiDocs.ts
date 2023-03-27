import SwaggerUI from 'swagger-ui'

import { fetchData } from 'utilities/fetchData'
import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import type { ApiDocsServices } from 'Types/SwaggerTypes'

const getApiSpecUrl = (baseUrl: string, specPath: string): string => {
  return `${baseUrl.replace(/\/$/, '')}${specPath}`
}

const appendSwaggerDiv = (container: HTMLElement, id: string): void => {
  const div = document.createElement('div')
  div.setAttribute('class',  'api-docs-wrap')
  div.setAttribute('id', id)

  container.appendChild(div)
}

export const renderApiDocs = async (container: HTMLElement, apiDocsPath: string, baseUrl: string, apiDocsAccountDataPath: string): Promise<void> => {
  const apiSpecs: ApiDocsServices = await fetchData<ApiDocsServices>(apiDocsPath)
  apiSpecs.apis.forEach( api => {
    const domId = api.system_name.replace(/_/g, '-')
    const url = getApiSpecUrl(baseUrl, api.path)
    appendSwaggerDiv(container, domId)
    SwaggerUI({
      url,
      // eslint-disable-next-line @typescript-eslint/naming-convention -- Swagger UI
      dom_id: `#${domId}`,
      requestInterceptor: (request) => autocompleteRequestInterceptor(request, apiDocsAccountDataPath, ''),
      tryItOutEnabled: true
    })
  })
}
