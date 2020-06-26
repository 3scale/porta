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
        [...examples, {summary: item.name, value: item.value}]
      ), [{summary: X_DATA_PARAMS_DESCRIPTIONS[xDataKey], value: '-'}])
    }
    : param
}

const updateResponseBody = (response: SwaggerResponse, accountData: AccountData): ResponseBody => (
  {
    ...response.body,
    paths: Object.keys(response.body.paths).reduce(
      (paths, key) => {
        const pathParameters = response.body.paths[key].get.parameters
        if (pathParameters) {
          paths[key] = {
            get: {
              ...response.body.paths[key].get,
              parameters: pathParameters.map(param => {
                return X_DATA_ATTRIBUTE in param ? addAutocompleteToParam(param, accountData) : param
              })
            }
          }
        }
        return paths
      }, {})
  }
)

// response.body.method is not present when fetching the spec,
// is present when doing a request to one of the paths
const isSpecFetched = (response: SwaggerResponse): boolean => !!response.body.method

export const autocompleteOAS3 = async (response: SwaggerResponse, accountDataUrl: string): SwaggerResponse => (
  isSpecFetched(response)
    ? response
    : fetchData(accountDataUrl)
      .then(data => {
        const accountData = data.results
        if (!accountData) {
          return response
        }
        const body = updateResponseBody(response, accountData)
        return {
          ...response,
          body,
          data: JSON.stringify(body),
          text: JSON.stringify(body)
        }
      })
)
