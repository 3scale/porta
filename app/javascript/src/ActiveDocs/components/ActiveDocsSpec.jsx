// @flow

import React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { fetchData } from 'utilities/utils'
import SwaggerUI from 'swagger-ui-react'
import 'swagger-ui-react/swagger-ui.css'

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

type Primitive = string | number | boolean

type AccountData = {
  [string]: Array<{name: string, value: string}> | []
}

type ActiveDocsSpecProps = {
  accountDataUrl: string,
  url: string,
}

type ParamArraySchema = {
  type: 'array',
  items: { type: Primitive }
}
type ParamEnumSchema = {
  enum: Array<Primitive>,
  items: { type: Primitive }
}

type Examples = Array<{
  summary: string,
  value: string
}>

type Param = {
  in: string,
  name: string,
  description?: string,
  required?: boolean,
  schema?: Primitive | ParamArraySchema | ParamEnumSchema,
  examples?: Examples
}

type SwaggerResponse = {
  body: {
    paths: {
      [string]: {
        parameters: Array<Param>,
        [string]: string | {}
      }
    },
    [string]: string | {}
  },
  data: string,
  headers: {},
  obj: {},
  ok: boolean,
  status: number,
  statusText: string,
  text: string,
  url: string
}

const addAutocompleteToParam = (param: Param, accountData: AccountData): Param => {
  const paramName = AUTOCOMPLETE_PARAMS_MAP[param.name]
  const autocompleteData = accountData[paramName]
  const paramHasAutocompleteData = autocompleteData.length > 0 &&
    autocompleteData.every(param => param.value !== '')

  return paramHasAutocompleteData
    ? {
      ...param,
      examples: autocompleteData.reduce((examples, item) => (
        [...examples, {summary: item.name, value: item.value}]
      ), [{ summary: 'Select an option to autocomplete', value: '-' }])
    }
    : param
}

const injectAccountDataToResponse = async (response: SwaggerResponse, accountDataUrl: string): Promise<SwaggerResponse> => {
  return new Promise(async (resolve, reject) => {
    const data = await fetchData(accountDataUrl)
    const accountData = data.results
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

const ActiveDocsSpec = ({ url, accountDataUrl }: ActiveDocsSpecProps) => (
  <SwaggerUI
    url={url}
    responseInterceptor={(response) => injectAccountDataToResponse(response, accountDataUrl)}
  />
)

const ActiveDocsSpecWrapper = (props: ActiveDocsSpecProps, id: string) => (
  createReactWrapper(<ActiveDocsSpec {...props} />, id)
)

export { ActiveDocsSpec, ActiveDocsSpecWrapper }
