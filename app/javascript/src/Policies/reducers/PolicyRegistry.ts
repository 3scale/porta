import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import { RegistryPolicy } from 'Policies/types'
import { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'
import { Reducer } from 'redux'

function updateRegistry (state: Array<RegistryPolicy>, action: FetchRegistrySuccessAction): Array<RegistryPolicy> {
  return [...action.payload]
}

// TODO: use combineReducers instead of createReducer
const RegistryReducer: Reducer<Array<RegistryPolicy>> = createReducer<Array<RegistryPolicy>>(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
