// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

function updatePolicyConfig (state: ChainPolicy, action: UpdatePolicyConfigAction): ChainPolicy {
  return action.policy
}

// TODO: use combineReducers instead of createReducer
// $FlowFixMe[signature-verification-failure] State types are very complex for Flow
const PolicyConfigReducer = createReducer<ChainPolicy>(initialState.policyConfig, {
  'UPDATE_POLICY_CONFIG': updatePolicyConfig
})

export default PolicyConfigReducer
