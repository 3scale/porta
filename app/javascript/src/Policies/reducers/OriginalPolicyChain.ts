import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { Reducer, ChainPolicy } from 'Policies/types'
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'

function setOriginalPolicyChain (state: Array<ChainPolicy>, action: SetOriginalPolicyChainAction): Array<ChainPolicy> {
  return [...[], ...action.payload]
}

// TODO: use combineReducers instead of createReducer
const OriginalChainReducer: Reducer<Array<ChainPolicy>> = createReducer<Array<ChainPolicy>>(initialState.originalChain, {
  'SET_ORIGINAL_POLICY_CHAIN': setOriginalPolicyChain
})

export default OriginalChainReducer
