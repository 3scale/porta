/* eslint-disable @typescript-eslint/no-unnecessary-condition */
/* eslint-disable @typescript-eslint/default-param-last */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-return */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/naming-convention */
/* TODO: this module needs to be properly typed !!! */

import { fetchData } from 'utilities/fetchData'

import type { Response as SwaggerUIResponse } from 'swagger-ui'
import type { AccountData } from 'Types/SwaggerTypes'

const X_DATA_ATTRIBUTE = 'x-data-threescale-name'

const X_DATA_PARAMS_DESCRIPTIONS = {
  user_keys: 'First user key from latest 5 applications',
  app_ids: 'Latest 5 applications (across all accounts and services)',
  app_keys: 'First application key from the latest five applications'
} as const

const addAutocompleteToParam = (param: any, accountData: AccountData): any => {
  const xDataKey = param[X_DATA_ATTRIBUTE] as keyof typeof X_DATA_PARAMS_DESCRIPTIONS
  const autocompleteData = accountData[xDataKey]
  const paramHasAutocompleteData = autocompleteData && autocompleteData.length > 0 &&
    autocompleteData.every(p => p.name !== '')

  return paramHasAutocompleteData
    ? {
      ...param,
      examples: autocompleteData.reduce<{ summary: string; value: string }[]>((examples, item) => (
        [...examples, { summary: item.name, value: item.value }]
      ), [{ summary: X_DATA_PARAMS_DESCRIPTIONS[xDataKey], value: '-' }])
    }
    : param
}

const injectParametersToPathOperation = (pathOperation: any, accountData: AccountData): any => {
  const operationParameters = pathOperation.parameters
  if (!operationParameters) return pathOperation
  const parametersWithAutocompleteData = operationParameters.map((param: any) => X_DATA_ATTRIBUTE in param ? addAutocompleteToParam(param, accountData) : param)
  return {
    ...pathOperation,
    parameters: parametersWithAutocompleteData
  }
}

const injectAutocompleteToCommonParameters = (parameters: any[], accountData: AccountData): any[] => parameters.map(
  param => X_DATA_ATTRIBUTE in param ? addAutocompleteToParam(param, accountData) : param
)

const injectParametersToPath = (
  path: Record<string, unknown>,
  commonParameters: any[] | null | undefined = [],
  accountData: AccountData
): any => (Object.keys(path).reduce<Record<string, unknown>>((updatedPath, item) => {
  updatedPath[item] = (item === 'parameters' && commonParameters)
    ? injectAutocompleteToCommonParameters(commonParameters, accountData)
    : injectParametersToPathOperation(path[item], accountData)
  return updatedPath
}, {}))

const injectAutocompleteToResponseBody = (responseBody: string | { paths?: Record<string, any> }, accountData: AccountData): any | string => {
  const res = (typeof responseBody !== 'string' && responseBody.paths && accountData) ? {
    ...responseBody,
    paths: Object.keys(responseBody.paths).reduce<Record<string, any>>((paths, path) => {
      const commonParameters = responseBody.paths![path].parameters
      paths[path] = injectParametersToPath(responseBody.paths![path], commonParameters, accountData)
      return paths
    }, {})
  } : responseBody
  return res
}

const injectServerToResponseBody = (responseBody: any | string, serviceEndpoint: string): any | string => {
  if (typeof responseBody === 'string') {
    return responseBody
  }

  const originalServers = responseBody.servers || []
  const servers = serviceEndpoint ? [{ url: serviceEndpoint }] : originalServers

  return {
    ...responseBody,
    servers
  }
}

export interface Response extends SwaggerUIResponse {
  body: {
    servers: unknown;
    paths: any;
  };
  data: string;
  text: string;
}

export const autocompleteOAS3 = async (response: SwaggerUIResponse, accountDataUrl: string, serviceEndpoint: string): Promise<Response> => {
  const bodyWithServer = injectServerToResponseBody(response.body, serviceEndpoint)
  const data = await fetchData<{ results: AccountData }>(accountDataUrl)

  let body = undefined
  try {
    body = data.results
      ? injectAutocompleteToResponseBody(bodyWithServer, data.results)
      : bodyWithServer
  } catch (error: unknown) {
    console.error(error)
    body = bodyWithServer
  }

  return {
    ...response,
    body,
    data: JSON.stringify(body),
    text: JSON.stringify(body)
  }
}
