// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateArray, parsePolicies } from 'Policies/util'

import type { RegistryState } from 'Policies/types'
import type { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'

function updateRegistry (state: RegistryState, action: FetchRegistrySuccessAction): RegistryState {
  return updateArray(state, parsePolicies(action.payload))
}

// TODO: use combineReducers instead of createReducer
const RegistryReducer = createReducer<RegistryState>(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
