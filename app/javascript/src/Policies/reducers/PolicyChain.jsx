// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, generateGuid, updateArray } from 'Policies/util'

import type { ChainState, ChainPolicy, RegistryPolicy } from 'Policies/types'
import type {
  AddPolicyToChainAction,
  FetchChainSuccessAction,
  SortPolicyChainAction,
  UpdatePolicyChainAction
} from 'Policies/actions/PolicyChain'

export type UpdateChainPolicies = FetchChainSuccessAction | SortPolicyChainAction

function createChainPolicy (policy: RegistryPolicy): ChainPolicy {
  return {...policy, ...{humanName: policy.humanName, enabled: true, removable: true, uuid: generateGuid()}}
}

function addPolicy (state: ChainState, action: AddPolicyToChainAction): ChainState {
  return state.concat([createChainPolicy(action.policy)])
}

function updateChain (_state: ChainState, action: UpdatePolicyChainAction): ChainState {
  return action.payload
}

function updatePolicies (state: ChainState, action: UpdateChainPolicies): ChainState {
  return updateArray(state, action.payload)
}

// TODO: use combineReducers instead of createReducer
const ChainReducer = createReducer<ChainState>(initialState.chain, {
  'ADD_POLICY_TO_CHAIN': addPolicy,
  'SORT_POLICY_CHAIN': updatePolicies,
  'LOAD_CHAIN_SUCCESS': updatePolicies,
  'FETCH_CHAIN_SUCCESS': updatePolicies,
  'UPDATE_POLICY_CHAIN': updateChain
})

export default ChainReducer
