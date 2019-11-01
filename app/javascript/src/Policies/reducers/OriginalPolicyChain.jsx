// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateArray } from 'Policies/util'

import type { ChainState } from 'Policies/types'
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'

function setOriginalPolicyChain (state: ChainState, action: SetOriginalPolicyChainAction): ChainState {
  return updateArray(state, action.payload)
}

// TODO: use combineReducers instead of createReducer
const OriginalChainReducer = createReducer<ChainState>(initialState.originalChain, {
  'SET_ORIGINAL_POLICY_CHAIN': setOriginalPolicyChain
})

export default OriginalChainReducer
