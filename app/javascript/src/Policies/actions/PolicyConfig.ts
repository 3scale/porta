import type {ChainPolicy} from 'Policies/types';

export type UpdatePolicyConfigAction = {
  type: 'UPDATE_POLICY_CONFIG',
  policy: ChainPolicy
};
export function updatePolicyConfig(policy: ChainPolicy): UpdatePolicyConfigAction {
  return { type: 'UPDATE_POLICY_CONFIG', policy }
}
