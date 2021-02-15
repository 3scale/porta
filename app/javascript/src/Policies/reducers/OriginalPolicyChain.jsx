// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { ChainPolicy } from 'Policies/types'
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'

function setOriginalPolicyChain (state: Array<ChainPolicy>, action: SetOriginalPolicyChainAction): Array<ChainPolicy> {
  return [...[], ...action.payload]
}

// TODO: use combineReducers instead of createReducer
// $FlowFixMe[signature-verification-failure] State types are very complex for Flow
const OriginalChainReducer = createReducer<Array<ChainPolicy>>(initialState.originalChain, {
  'SET_ORIGINAL_POLICY_CHAIN': setOriginalPolicyChain
})

export default OriginalChainReducer
