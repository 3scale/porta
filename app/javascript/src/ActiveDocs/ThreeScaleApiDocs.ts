import $ from 'jquery'
import SwaggerUI from 'swagger-ui'

import { fetchData } from 'utilities/fetchData'

import type { ApiDocsServices } from 'Types/SwaggerTypes'

import { autocompleteInterceptor } from './OAS3Autocomplete'

const getApiSpecUrl = (baseUrl: string, specPath: string): string => {
  return `${baseUrl.replace(/\/$/, '')}/${specPath}`
}

const appendSwaggerDiv = (container: HTMLElement, id: string): void => {
  $(container).append($(`<div class="api-docs-wrap" id="${id}" ></div>`))
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
      responseInterceptor: (response) => autocompleteInterceptor(response, apiDocsAccountDataPath, '', url),
      tryItOutEnabled: true
    })
  })
}
