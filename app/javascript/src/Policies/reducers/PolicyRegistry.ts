import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { Reducer, RegistryPolicy } from 'Policies/types'
import type { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'

function updateRegistry (state: Array<RegistryPolicy>, action: FetchRegistrySuccessAction): Array<RegistryPolicy> {
  return [...[], ...action.payload]
}

// TODO: use combineReducers instead of createReducer
const RegistryReducer: Reducer<Array<RegistryPolicy>> = createReducer<Array<RegistryPolicy>>(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
