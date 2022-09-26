import { setOriginalPolicyChain } from 'Policies/actions/OriginalPolicyChain'
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

it('#setOriginalPolicyChain should create an action', () => {
  const payload = chainPolicy
  expect(setOriginalPolicyChain(payload)).toEqual({ type: 'SET_ORIGINAL_POLICY_CHAIN', payload })
})
