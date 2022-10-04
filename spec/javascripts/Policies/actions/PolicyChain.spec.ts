import * as PolicyChain from 'Policies/actions/PolicyChain'

import type { ChainPolicy, RegistryPolicy } from 'Policies/types'

const registryPolicy: RegistryPolicy = {
  name: 'name',
  configuration: {},
  version: '1',
  $schema: '{}',
  description: ['description'],
  summary: 'summary',
  data: undefined,
  humanName: 'Mr. Human'
}

const chainPolicy: ChainPolicy = {
  ...registryPolicy,
  uuid: '123',
  enabled: false,
  removable: true
}

it('#addPolicyToChain should create an action', () => {
  const policy = registryPolicy
  expect(PolicyChain.addPolicyToChain(policy)).toEqual({ type: 'ADD_POLICY_TO_CHAIN', policy })
})

it('#removePolicy should create an action', () => {
  expect(PolicyChain.removePolicy(chainPolicy)).toEqual({ type: 'REMOVE_POLICY_FROM_CHAIN', policy: chainPolicy })
})

it('#sortPolicyChain should create an action', () => {
  const payload = [chainPolicy]
  expect(PolicyChain.sortPolicyChain(payload)).toEqual({ type: 'SORT_POLICY_CHAIN', payload })
})

it('#updatePolicyInChain should create an action', () => {
  const policyConfig = chainPolicy
  expect(PolicyChain.updatePolicyInChain(policyConfig)).toEqual({ type: 'UPDATE_POLICY_IN_CHAIN', policyConfig })
})

it('#updatePolicyChain should create an action', () => {
  const payload = [chainPolicy]
  expect(PolicyChain.updatePolicyChain(payload)).toEqual({ type: 'UPDATE_POLICY_CHAIN', payload })
})

it('#loadChain should create an action', () => {
  const policiesConfig = [chainPolicy]
  expect(PolicyChain.loadChain(policiesConfig)).toEqual({ type: 'LOAD_CHAIN', policiesConfig })
})

it('#loadChainSuccess should create an action', () => {
  const payload = [chainPolicy]
  expect(PolicyChain.loadChainSuccess(payload)).toEqual({ type: 'LOAD_CHAIN_SUCCESS', payload })
})

it('#loadChainError should create an action', () => {
  const payload = chainPolicy
  expect(PolicyChain.loadChainError(payload)).toEqual({ type: 'LOAD_CHAIN_ERROR', payload })
})

it('#fetchChain should create an action to use the redux api middleware', () => {
  expect(PolicyChain.fetchChain('serviceId')).toMatchInlineSnapshot(`
    Object {
      "@@redux-api-middleware/RSAA": Object {
        "credentials": "same-origin",
        "endpoint": "/admin/api/services/serviceId/proxy/policies.json",
        "method": "GET",
        "types": Array [
          Object {
            "type": "FETCH_CHAIN_REQUEST",
          },
          Object {
            "type": "FETCH_CHAIN_SUCCESS",
          },
          Object {
            "type": "FETCH_CHAIN_ERROR",
          },
        ],
      },
    }
  `)
})
