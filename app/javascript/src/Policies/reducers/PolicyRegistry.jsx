// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateArray, parsePolicies } from 'Policies/util'

import type { RegistryPolicy } from 'Policies/types'
import type { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'

function updateRegistry (state: Array<RegistryPolicy>, action: FetchRegistrySuccessAction): Array<RegistryPolicy> {
  return updateArray(state, parsePolicies(action.payload))
}

// TODO: use combineReducers instead of createReducer
const RegistryReducer = createReducer<Array<RegistryPolicy>>(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
