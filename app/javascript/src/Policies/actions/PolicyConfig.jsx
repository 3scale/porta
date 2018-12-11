// @flow

import type { ChainPolicy } from 'types/Policies'

export type UpdatePolicyConfigAction = { type: 'UPDATE_POLICY_CONFIG', policyConfig: ChainPolicy }
export function updatePolicyConfig (policyConfig: ChainPolicy): UpdatePolicyConfigAction {
  return { type: 'UPDATE_POLICY_CONFIG', policyConfig }
}
