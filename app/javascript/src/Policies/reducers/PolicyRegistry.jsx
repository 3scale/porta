// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateArray, parsePolicies } from 'Policies/util'

import type { RegistryState } from 'Policies/types/State'
import type { FetchRegistrySuccessAction } from 'Policies/actions/PolicyRegistry'

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
