// @flow

import { fetchData } from 'utilities/utils'
import type {
  AccountData,
  Param,
  SwaggerResponse
} from 'Types/SwaggerTypes'

const AUTOCOMPLETE_PARAMS_MAP = {
  'app_key': 'app_keys',
  'app_id': 'app_ids',
  'application_id': 'application_ids',
  'user_key': 'user_keys',
  'user_id': 'user_ids',
  'account_id': 'account_ids',
  'metric_name': 'metric_names',
  'metric_id': 'metric_ids',
  'backend_api_metric_name': 'backend_api_metric_names',
  'service_id': 'service_ids',
  'admin_id': 'admin_ids',
  'service_plan_id': 'service_plan_ids',
  'application_plan_id': 'application_plan_ids',
  'account_plan_id': 'account_plan_ids',
  'client_id': 'client_ids',
  'client_secret': 'client_secrets',
  'service_token': 'service_tokens',
  'access_token': 'access_token'
}

const addAutocompleteToParam = (param: Param, accountData: AccountData): Param => {
  const paramName = AUTOCOMPLETE_PARAMS_MAP[param.name]
  const autocompleteData = accountData[paramName]
  const paramHasAutocompleteData = autocompleteData && autocompleteData.length > 0 &&
   autocompleteData.every(param => param.name !== '')

  return paramHasAutocompleteData
    ? {
      ...param,
      examples: autocompleteData.reduce((examples, item) => (
        [...examples, {summary: item.name, value: item.value}]
      ), [{ summary: 'Select an option to autocomplete', value: '-' }])
    }
    : param
}

export const autocompleteOAS3 = async (response: SwaggerResponse, accountDataUrl: string): Promise<SwaggerResponse> => {
  return new Promise(async (resolve, reject) => {
    const data = await fetchData(accountDataUrl)
    const accountData = data.results
    if (!accountData) {
      resolve(response)
    }
    const body = {
      ...response.body,
      paths: Object.keys(response.body.paths).reduce(
        (paths, key) => {
          const pathParameters = response.body.paths[key].parameters
          if (pathParameters) {
            paths[key] = {
              ...response.body.paths[key],
              parameters: pathParameters.map(param => addAutocompleteToParam(param, accountData))
            }
          }
          return paths
        }
        , {})
    }
    resolve({
      ...response,
      body,
      data: JSON.stringify(body),
      text: JSON.stringify(body)
    })
  })
}
