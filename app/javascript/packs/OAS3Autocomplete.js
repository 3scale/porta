// @flow

import { fetchData } from 'utilities/utils'
import type {
  AccountData,
  Param,
  ResponseBody,
  SwaggerResponse
} from 'Types/SwaggerTypes'

const AUTOCOMPLETE_PARAMS_MAP = {
  'app_key': {
    description: 'First application key from the latest five applications',
    name: 'app_keys'
  },
  'app_id': {
    description: 'Latest 5 applications (across all accounts and services)',
    name: 'app_ids'
  },
  'application_id': {
    description: 'Latest 5 applications',
    name: 'application_ids'
  },
  'user_key': {
    description: 'First user key from latest 5 applications',
    name: 'user_keys'
  },
  'user_id': {
    description: 'First user (admin) of the latest 5 account',
    name: 'user_ids'
  },
  'account_id': {
    description: 'Latest 5 accounts',
    name: 'account_ids'
  },
  'metric_name': {
    description: 'Latest 5 metrics',
    name: 'metric_names'
  },
  'metric_id': {
    description: 'Latest 5 metrics',
    name: 'metric_ids'
  },
  'backend_api_metric_name': {
    description: 'Backend API metric name',
    name: 'backend_api_metric_names'
  },
  'service_id': {
    description: 'Latest 5 services',
    name: 'service_ids'
  },
  'admin_id': {
    description: 'Latest 5 users (admin) from your account',
    name: 'admin_ids'
  },
  'service_plan_id': {
    description: 'Latest 5 service plans',
    name: 'service_plan_ids'
  },
  'application_plan_id': {
    description: 'Latest 5 application plans',
    name: 'application_plan_ids'
  },
  'account_plan_id': {
    description: 'Latest 5 account plans',
    name: 'account_plan_ids'
  },
  'client_id': {
    description: 'Client IDs from the latest five applications',
    name: 'client_ids'
  },
  'client_secret': {
    description: 'Client secrets from the latest five applications',
    name: 'client_secrets'
  },
  'service_token': {
    description: 'Service Token',
    name: 'service_tokens'
  },
  'access_token': {
    description: 'Access Token',
    name: 'access_token'
  }
}

const addAutocompleteToParam = (param: Param, accountData: AccountData): Param => {
  const paramName = AUTOCOMPLETE_PARAMS_MAP[param.name].name
  const autocompleteData = accountData[paramName]
  const paramHasAutocompleteData = autocompleteData && autocompleteData.length > 0 &&
   autocompleteData.every(param => param.name !== '')

  return paramHasAutocompleteData
    ? {
      ...param,
      examples: autocompleteData.reduce((examples, item) => (
        [...examples, {summary: item.name, value: item.value}]
      ), [{summary: AUTOCOMPLETE_PARAMS_MAP[param.name].description, value: ''}])
    }
    : param
}

const updateResponseBody = (response: SwaggerResponse, accountData: AccountData): ResponseBody => (
  {
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
)

export const autocompleteOAS3 = async (response: SwaggerResponse, accountDataUrl: string): Promise<SwaggerResponse> => {
  return new Promise(async (resolve, reject) => {
    const data = await fetchData(accountDataUrl)
    const accountData = data.results
    if (!accountData) {
      return resolve(response)
    }

    const body = updateResponseBody(response, accountData)

    resolve({
      ...response,
      body,
      data: JSON.stringify(body),
      text: JSON.stringify(body)
    })
  })
}
