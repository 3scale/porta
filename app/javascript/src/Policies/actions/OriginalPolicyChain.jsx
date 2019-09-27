// @flow

import type { ChainPolicy } from 'Policies/types/Policies'

export type SetOriginalPolicyChainAction = { type: 'SET_ORIGINAL_POLICY_CHAIN', payload: Array<ChainPolicy> }
export function setOriginalPolicyChain (payload: Array<ChainPolicy>): SetOriginalPolicyChainAction {
  return { type: 'SET_ORIGINAL_POLICY_CHAIN', payload }
}
