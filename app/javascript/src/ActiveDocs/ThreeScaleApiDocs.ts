import SwaggerUI from 'swagger-ui'
// this is how SwaggerUI imports this function https://github.com/swagger-api/swagger-ui/pull/6208
import { execute } from 'swagger-client/es/execute'

import { fetchData } from 'utilities/fetchData'
import { safeFromJsonString } from 'utilities/json-utils'
import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import type { ApiDocsServices, BackendApiReportBody, BackendApiTransaction, BodyValue, BodyValueObject, FormData } from 'Types/SwaggerTypes'
import type { ExecuteData } from 'swagger-client/es/execute'
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
 * A recursive function that traverses the tree of the multi-level object `data`
 * and for every leaf (i.e. value of primitive type) adds the value to `formData` single-level object,
 * with the key that is the `path` to that leaf, e.g. 'paramName[nestedArray][0][arrayProp]'
 * @param formData single-level object used as accumulator
 * @param data current node of the object
 * @param parentKey part of the formData key inherited from the upper level
 */
const buildFormData = (formData: FormData, data: BodyValue, parentKey?: string) => {
  if (data && typeof data === 'object') {
    const dataObject = data as BodyValueObject
    Object.keys(dataObject).forEach((key: string) => {
      buildFormData(formData, dataObject[key], parentKey ? `${parentKey}[${key}]` : key)
    })
  } else {
    if (parentKey) {
      formData[parentKey] = data ? data : ''
    }
  }
}

/**
 * Transforms an object into form data representation. Does not URL-encode, because it will be done by
 * swagger-client itself
 * Returns an empty object if the argument is not an object
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
 *   'an_array[1][extra_param]': 'with whitespace'
 * }
 * @param object
 */
export const objectToFormData = (object: BodyValueObject): FormData => {
  if (typeof object !== 'object' || Array.isArray(object)) {
    return {}
  }
  const formData: FormData = {}
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
export const transformReportRequestBody = (body: BackendApiReportBody): FormData => {
  if (Array.isArray(body.transactions)) {
    body.transactions = body.transactions.reduce((acc: BackendApiTransaction[], transaction) => {
      let value = undefined
      if (typeof transaction === 'object') {
        value = transaction
      } else {
        value = safeFromJsonString<BackendApiTransaction>(transaction)
      }
      if (value) {
        acc.push(value)
      }
      return acc
    }, [])
  }
  return objectToFormData(body)
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
