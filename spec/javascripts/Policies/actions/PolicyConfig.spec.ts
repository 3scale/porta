import { updatePolicyConfig } from "Policies/actions/PolicyConfig";
import { ChainPolicy } from 'Policies/types'

it('#describePolicyConfig should create an action', () => {
  const policy = { uuid: 'uuid', enabled: true, removable: false }
  expect(updatePolicyConfig(policy)).toEqual({ type: 'UPDATE_POLICY_CONFIG', policy })
})
