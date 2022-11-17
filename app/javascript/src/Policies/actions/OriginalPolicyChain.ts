import type { ChainPolicy } from 'Policies/types'
import type { Action } from 'redux'

export type SetOriginalPolicyChainAction = Action<'SET_ORIGINAL_POLICY_CHAIN'> & {
  payload: ChainPolicy[];
}
export function setOriginalPolicyChain (payload: ChainPolicy[]): SetOriginalPolicyChainAction {
  return { type: 'SET_ORIGINAL_POLICY_CHAIN', payload }
}
