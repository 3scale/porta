// @flow

import type { ChainPolicy } from 'Policies/types/Policies'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

import { initialState } from 'Policies/reducers/initialState'
import { updateObject, createReducer } from 'Policies/reducers/util'

function updatePolicyConfig (state: ChainPolicy, action: UpdatePolicyConfigAction): ChainPolicy {
  return updateObject(state, action.policyConfig)
}

const PolicyConfigReducer = createReducer(initialState.policyConfig, {
  'UPDATE_POLICY_CONFIG': updatePolicyConfig
})

export default PolicyConfigReducer
