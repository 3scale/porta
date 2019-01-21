// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateArray } from 'Policies/reducers/util'

import type { RegistryState } from 'Policies/types/State'
import type { RawPolicy, RawRegistry, RegistryPolicy } from 'Policies/types/Policies'
import type { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'

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

// eslint-disable-next-line space-infix-ops
// const RegistryReducer = createReducer<RegistryState>(initialState.registry, {
// $FlowFixMe TODO: in order to fully type createReducer, set UIState and re-enable flow. (use lines above)
const RegistryReducer = createReducer(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
