// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { RegistryPolicy } from 'Policies/types'
import type { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'

function updateRegistry (state: Array<RegistryPolicy>, action: FetchRegistrySuccessAction): Array<RegistryPolicy> {
  return [...[], ...action.payload]
}

// TODO: use combineReducers instead of createReducer
// $FlowFixMe[signature-verification-failure] State types are very complex for Flow
const RegistryReducer = createReducer<Array<RegistryPolicy>>(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
