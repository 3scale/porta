import { updatePolicyConfig } from 'Policies/actions/PolicyConfig'
import { ChainPolicy } from 'Policies/types'

const chainPolicy: ChainPolicy = {
  name: 'name',
  configuration: {},
  version: '1',
  $schema: '{}',
  description: ['description'],
  summary: 'summary',
  data: undefined,
  humanName: 'Mr. Human',
  uuid: '123',
  enabled: false,
  removable: true
}

it('#describePolicyConfig should create an action', () => {
  const policy = chainPolicy
  expect(updatePolicyConfig(policy)).toEqual({ type: 'UPDATE_POLICY_CONFIG', policy })
})
