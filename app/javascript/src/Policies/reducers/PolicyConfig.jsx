// @flow

import type { ChainPolicy } from '../types/Policies'
import type { UpdatePolicyConfigAction } from '../actions/PolicyConfig'

import { initialState } from './initialState'
import { updateObject, createReducer } from './util'

function updatePolicyConfig (state: ChainPolicy, action: UpdatePolicyConfigAction): ChainPolicy {
  return updateObject(state, action.policyConfig)
}

const PolicyConfigReducer = createReducer(initialState.policyConfig, {
  'UPDATE_POLICY_CONFIG': updatePolicyConfig
})

export default PolicyConfigReducer
