import type { ChainPolicy } from 'Policies/types'
import type { Action } from 'redux'

export type UpdatePolicyConfigAction = Action<'UPDATE_POLICY_CONFIG'> & {
  policy: ChainPolicy;
}
export function updatePolicyConfig (policy: ChainPolicy): UpdatePolicyConfigAction {
  return { type: 'UPDATE_POLICY_CONFIG', policy }
}
