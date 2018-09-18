// @flow

import { initialState } from './initialState'
import { createReducer, updateArray } from './util'

import type { RegistryState } from '../types/State'
import type { RawPolicy, RawRegistry, RegistryPolicy } from '../types/Policies'
import type { FetchRegistrySuccessAction } from '../actions/PolicyRegistry'

function parsePolicies (registry: RawRegistry): Array<RegistryPolicy> {
  let policies: Array<RegistryPolicy> = []
  for (let key in registry) {
    registry[key].forEach(policy => policies.push(parsePolicy(key, policy)))
  }
  return policies
}

function parsePolicy (key: string, policy: RawPolicy): RegistryPolicy {
  return Object.assign({},
    {
      $schema: policy.$schema,
      name: key,
      humanName: policy.name,
      schema: policy.configuration,
      version: policy.version,
      summary: policy.summary,
      description: policy.description,
      configuration: {}
    })
}

function updateRegistry (state: RegistryState, action: FetchRegistrySuccessAction): RegistryState {
  return updateArray(state, parsePolicies(action.payload))
}

const RegistryReducer = createReducer(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
