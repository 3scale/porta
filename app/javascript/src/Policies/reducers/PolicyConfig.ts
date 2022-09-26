import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import { ChainPolicy } from 'Policies/types'
import { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'
import { Reducer } from 'redux'

function updatePolicyConfig (state: ChainPolicy, action: UpdatePolicyConfigAction): ChainPolicy {
  return action.policy
}

// TODO: use combineReducers instead of createReducer
const PolicyConfigReducer: Reducer<ChainPolicy> = createReducer<ChainPolicy>(initialState.policyConfig, {
  'UPDATE_POLICY_CONFIG': updatePolicyConfig
})

export default PolicyConfigReducer
