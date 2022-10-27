/* eslint-disable @typescript-eslint/naming-convention */
import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { RegistryPolicy } from 'Policies/types'
import type { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'
import type { Reducer } from 'redux'

function updateRegistry (state: RegistryPolicy[], action: FetchRegistrySuccessAction): RegistryPolicy[] {
  return [...action.payload]
}

// TODO: use combineReducers instead of createReducer
const RegistryReducer: Reducer<RegistryPolicy[]> = createReducer<RegistryPolicy[]>(initialState.registry, {
  'LOAD_REGISTRY_SUCCESS': updateRegistry,
  'FETCH_REGISTRY_SUCCESS': updateRegistry
})

export default RegistryReducer
