// @flow

import { fetchData } from 'utilities/utils'
import type {
  AccountData,
  Param,
  ResponseBody,
  SwaggerResponse
} from 'Types/SwaggerTypes'

const X_DATA_ATTRIBUTE = 'x-data-threescale-name'

const X_DATA_PARAMS_DESCRIPTIONS = {
  user_keys: 'First user key from latest 5 applications',
  app_ids: 'Latest 5 applications (across all accounts and services)',
  app_keys: 'First application key from the latest five applications'
}

const addAutocompleteToParam = (param: Param, accountData: AccountData): Param => {
  const xDataKey = param[X_DATA_ATTRIBUTE]
  const autocompleteData = accountData[xDataKey]
  const paramHasAutocompleteData = autocompleteData && autocompleteData.length > 0 &&
    autocompleteData.every(param => param.name !== '')

  return paramHasAutocompleteData
    ? {
      ...param,
      examples: autocompleteData.reduce((examples, item) => (
        [...examples, { summary: item.name, value: item.value }]
      ), [{ summary: X_DATA_PARAMS_DESCRIPTIONS[xDataKey], value: '-' }])
    }
    : param
}

const getPathParameters = (path) => (
  Object.keys(path).reduce((params, item) => {
    params[item] = path[item].parameters
    return params
  }, {})
)

const injectParametersToPath = (path, pathParameters, accountData) => (
  Object.keys(pathParameters).reduce((parameters, item) => {
    parameters[item] = {
      ...path[item],
      parameters: pathParameters[item]
        ? pathParameters[item].map(param => X_DATA_ATTRIBUTE in param ? addAutocompleteToParam(param, accountData) : param)
        : []
    }
    return parameters
  }, {})
)

const injectAutocompleteToResponseBody = (responseBody: ResponseBody, accountData: AccountData): ResponseBody => (
  {
    ...responseBody,
    paths: Object.keys(responseBody.paths).reduce(
      (paths, key) => {
        const pathParameters = getPathParameters(responseBody.paths[key])
        if (pathParameters) {
          paths[key] = injectParametersToPath(responseBody.paths[key], pathParameters, accountData)
        }
        return paths
      }, {})
  }
)

const injectServerToResponseBody = (responseBody: ResponseBody, serviceEndpoint: string): ResponseBody => {
  const originalServers = responseBody.servers || []
  const servers = serviceEndpoint ? [{ url: serviceEndpoint }] : originalServers

  return {
    ...responseBody,
    servers
  }
}

// response.body.method is not present when fetching the spec,
// is present when doing a request to one of the paths
const isSpecFetched = (response: SwaggerResponse): boolean => !!response.body.method

export const autocompleteOAS3 = async (response: SwaggerResponse, accountDataUrl: string, serviceEndpoint: string): SwaggerResponse => {
  if (isSpecFetched(response)) {
    return response
  }

  const bodyWithServer = injectServerToResponseBody(response.body, serviceEndpoint)
  const body = await fetchData(accountDataUrl)
    .then(data => (
      data.results
        ? injectAutocompleteToResponseBody(bodyWithServer, data.results)
        : bodyWithServer
    ))
    .catch(error => {
      console.log(error)
      return bodyWithServer
    })

  return {
    ...response,
    body,
    data: JSON.stringify(body),
    text: JSON.stringify(body)
  }
}
