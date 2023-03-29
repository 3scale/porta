import SwaggerUI from 'swagger-ui'
// this is how SwaggerUI imports this function https://github.com/swagger-api/swagger-ui/pull/6208
import { execute } from 'swagger-client/es/execute'

import { fetchData } from 'utilities/fetchData'
import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import type { ApiDocsServices, BackendApiReportBody, BackendApiTransaction, ExecuteData } from 'Types/SwaggerTypes'
import type { SwaggerUIPlugin } from 'swagger-ui'

const getApiSpecUrl = (baseUrl: string, specPath: string): string => {
  return `${baseUrl.replace(/\/$/, '')}${specPath}`
}

const appendSwaggerDiv = (container: HTMLElement, id: string): void => {
  const div = document.createElement('div')
  div.setAttribute('class',  'api-docs-wrap')
  div.setAttribute('id', id)

  container.appendChild(div)
}

/**
 * when using Record notation, the following error is thrown:
 * 'TS2456: Type alias 'BodyValue' circularly references itself.'
 */
// eslint-disable-next-line @typescript-eslint/consistent-indexed-object-style
type BodyValue = boolean | number | string | { [key: string]: BodyValue }

/**
 * Transforms an object into form data representation, also URL-encoding the values,
 * Example:
 * {
 *   a_string: 'hello',
 *   an_array: [
 *     { first: 1 },
 *     { second: 1, extra_param: 'with whitespace'}
 *   ]
 * }
 * =>
 * {
 *   a_string: 'hello',
 *   'an_array[0][first]': '1',
 *   'an_array[1][second]': '1',
 *   'an_array[1][extra_param]': 'with%20whitespace'
 * }
 * @param object
 */
export const objectToFormData = (object: BodyValue): Record<string, boolean | number | string> => {
  const buildFormData = (formData: Record<string, boolean | number | string>, data: BodyValue, parentKey?: string) => {
    if (data && typeof data === 'object') {
      Object.keys(data).forEach((key: string) => {
        buildFormData(formData, data[key], parentKey ? `${parentKey}[${key}]` : key)
      })
    } else {
      if (parentKey) {
        formData[parentKey] = data ? data : ''
      }
    }
  }
  const formData = {}
  buildFormData(formData, object)
  return formData
}

/**
 * Transforms the request body of the Service Management API Report, as
 * SwaggerUI (or rather swagger-js) does not serialize arrays of objects properly
 * The hack is to process the request body in two steps:
 * 1. normalize the 'transactions' array, as its elements may be either an object (if the value is taken
 *    from the example in the spec), or as a serialized JSON (if the field is changed manually)
 * 2. "flatten" the objects by transforming them into form-data structure with the entries like
 *    'transactions[0][app_id]': 'example'
 *    'transactions[0][usage][hits]': 1
 * @param body BackendApiReportBody
 */
export const transformReportRequestBody = (body: BackendApiReportBody): Record<string, boolean | number | string> => {
  if (Array.isArray(body.transactions)) {
    body.transactions = body.transactions.map(transaction => {
      switch (typeof transaction) {
        case 'object':
          return transaction
        case 'string':
          try {
            return JSON.parse(transaction) as BackendApiTransaction
          } catch (error: unknown) {
            return null
          }
        default:
          return null
      }
    }).filter(element => element != null) as BackendApiTransaction[]
  }
  return objectToFormData(body as BodyValue)
}

const RequestBodyTransformerPlugin: SwaggerUIPlugin = () => {
  return {
    fn: {
      execute: (req: ExecuteData): unknown => {
        if (req.contextUrl.includes('api_docs/services/service_management_api.json')
            && req.operationId === 'report'
            && req.requestBody) {
          req.requestBody = transformReportRequestBody(req.requestBody as BackendApiReportBody)
        }
        // eslint-disable-next-line @typescript-eslint/no-unsafe-call
        return execute(req)
      }
    }
  }
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
      tryItOutEnabled: true,
      plugins: [
        RequestBodyTransformerPlugin
      ]
    })
  })
}
