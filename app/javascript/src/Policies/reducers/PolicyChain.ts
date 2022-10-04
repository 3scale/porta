import { initialState } from 'Policies/reducers/initialState'
import { createReducer, generateGuid } from 'Policies/util'

import type { ChainPolicy, RegistryPolicy } from 'Policies/types'
import type {
  AddPolicyToChainAction,
  FetchChainSuccessAction,
  SortPolicyChainAction,
  UpdatePolicyChainAction
} from 'Policies/actions/PolicyChain'
import type { Reducer } from 'redux'

export type UpdateChainPolicies = FetchChainSuccessAction | SortPolicyChainAction

function createChainPolicy (policy: RegistryPolicy): ChainPolicy {
  return { ...policy, humanName: policy.humanName, enabled: true, removable: true, uuid: generateGuid() }
}

function addPolicy (state: Array<ChainPolicy>, action: AddPolicyToChainAction): Array<ChainPolicy> {
  return state.concat([createChainPolicy(action.policy)])
}

function updateChain (_state: Array<ChainPolicy>, action: UpdatePolicyChainAction): Array<ChainPolicy> {
  return action.payload
}

function updatePolicies (state: Array<ChainPolicy>, action: UpdateChainPolicies): Array<ChainPolicy> {
  return [...action.payload]
}

// TODO: use combineReducers instead of createReducer
const ChainReducer: Reducer<Array<ChainPolicy>> = createReducer<Array<ChainPolicy>>(initialState.chain, {
  'ADD_POLICY_TO_CHAIN': addPolicy,
  'SORT_POLICY_CHAIN': updatePolicies,
  'LOAD_CHAIN_SUCCESS': updatePolicies,
  'FETCH_CHAIN_SUCCESS': updatePolicies,
  'UPDATE_POLICY_CHAIN': updateChain
})

export default ChainReducer
