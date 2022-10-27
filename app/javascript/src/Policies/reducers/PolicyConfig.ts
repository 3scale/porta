/* eslint-disable @typescript-eslint/naming-convention */
import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'
import type { Reducer } from 'redux'

function updatePolicyConfig (state: ChainPolicy, action: UpdatePolicyConfigAction): ChainPolicy {
  return action.policy
}

// TODO: use combineReducers instead of createReducer
const PolicyConfigReducer: Reducer<ChainPolicy> = createReducer<ChainPolicy>(initialState.policyConfig, {
  'UPDATE_POLICY_CONFIG': updatePolicyConfig
})

export default PolicyConfigReducer
