// @flow

import { initialState } from 'Policies/reducers/initialState'
import { updateObject, createReducer } from 'Policies/util'

import type { ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

function updatePolicyConfig (state: ChainPolicy, action: UpdatePolicyConfigAction): ChainPolicy {
  return updateObject(state, action.policyConfig)
}

// TODO: use combineReducers instead of createReducer
const PolicyConfigReducer = createReducer<ChainPolicy>(initialState.policyConfig, {
  'UPDATE_POLICY_CONFIG': updatePolicyConfig
})

export default PolicyConfigReducer
