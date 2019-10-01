// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateArray } from 'Policies/util'
import type { ChainState } from 'Policies/types/State'
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'

function setOriginalPolicyChain (state: ChainState, action: SetOriginalPolicyChainAction): ChainState {
  return updateArray(state, action.payload)
}

// eslint-disable-next-line space-infix-ops
// const ChainReducer = createReducer<ChainState>(initialState.chain, {
// $FlowFixMe TODO: in order to fully type createReducer, set UIState and re-enable flow. (use lines above)
const OriginalChainReducer = createReducer(initialState.originalChain, {
  'SET_ORIGINAL_POLICY_CHAIN': setOriginalPolicyChain
})

export default OriginalChainReducer
