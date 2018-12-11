// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, generateGuid, updateArray } from 'Policies/reducers/util'
import type { ChainState } from 'Policies/types/State'
import type { ChainPolicy, RegistryPolicy } from 'Policies/types/Policies'
import type {
  AddPolicyToChainAction,
  FetchChainSuccessAction,
  SortPolicyChainAction,
  UpdatePolicyChainAction
} from 'Policies/actions/PolicyChain'

type UpdateChainPolicies = FetchChainSuccessAction | SortPolicyChainAction

function createChainPolicy (policy: RegistryPolicy): ChainPolicy {
  return {...policy, ...{schema: policy.schema, humanName: policy.humanName, enabled: true, removable: true, uuid: generateGuid()}}
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

const ChainReducer = createReducer(initialState.chain, {
  'ADD_POLICY_TO_CHAIN': addPolicy,
  'SORT_POLICY_CHAIN': updatePolicies,
  'LOAD_CHAIN_SUCCESS': updatePolicies,
  'FETCH_CHAIN_SUCCESS': updatePolicies,
  'UPDATE_POLICY_CHAIN': updateChain
})

export default ChainReducer
