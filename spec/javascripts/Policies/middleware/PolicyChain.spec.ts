import {
  convertToChainPolicy,
  findRegistryPolicy,
  loadChain,
  policyChainMiddleware,
  removePolicy,
  updatePolicy
} from 'Policies/middleware/PolicyChain'
import { loadChainError, updatePolicyChain } from 'Policies/actions/PolicyChain'
import * as utils from 'Policies/util'

import type { ChainPolicy, PolicyChainMiddlewareAction, PolicyConfig, RegistryPolicy, Store } from 'Policies/types'

const policyConfig: PolicyConfig = {
  name: 'name',
  configuration: {},
  version: '1',
  enabled: false
}

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

const validPolicy: PolicyConfig = { name: 'echo', version: 'builtin', configuration: { config: 'bond' } as any, enabled: true }
const wrongPolicy: PolicyConfig = { name: 'foo', version: 'builtin', configuration: {}, enabled: true }

const create = () => {
  const registry = [
    { name: 'echo', configuration: {}, summary: 'ECHO', description: 'ECHO', humanName: 'ECHO', version: 'builtin' }
  ]

  const chain = [chainPolicy]

  const store = {
    getState: jest.fn(() => ({ registry, chain })),
    dispatch: jest.fn()
  }
  const next = jest.fn()
  const invoke = (action: PolicyChainMiddlewareAction) => policyChainMiddleware(store as unknown as Store)(next)(action)

  return { store, next, invoke }
}

describe('#policyChainMiddleware', () => {
  const { invoke, store, next } = create()

  beforeEach(() => {
    store.dispatch.mockClear()
  })

  it('Passes through non of middleware actions', () => {
    const action = { type: 'TEST' }
    void invoke(action as PolicyChainMiddlewareAction)

    expect(next).toHaveBeenCalledWith(action)
  })

  it('Dispatches SET_ORIGINAL_POLICY_CHAIN and LOAD_CHAIN_SUCCESS action', () => {
    void invoke({ type: 'LOAD_CHAIN', policiesConfig: [validPolicy] })

    expect(store.dispatch.mock.calls[0][0].type).toBe('SET_ORIGINAL_POLICY_CHAIN')
    expect(store.dispatch.mock.calls[0][0].payload[0].data).toEqual(validPolicy.configuration)

    expect(store.dispatch.mock.calls[1][0].type).toBe('LOAD_CHAIN_SUCCESS')
    expect(store.dispatch.mock.calls[1][0].payload[0].data).toEqual(validPolicy.configuration)
  })

  it('Dispatches LOAD_CHAIN_ERROR action', () => {
    void invoke({ type: 'LOAD_CHAIN', policiesConfig: [wrongPolicy] })

    expect(store.dispatch).toHaveBeenCalledWith(loadChainError({}))
  })

  it('Dispatches SET_ORIGINAL_POLICY_CHAIN and LOAD_CHAIN_SUCCESS action only with valid policies', () => {
    void invoke({ type: 'LOAD_CHAIN', policiesConfig: [wrongPolicy, validPolicy] })

    expect(store.dispatch).toHaveBeenCalledWith(loadChainError({}))
    expect(store.dispatch).toHaveBeenCalledWith({ type: 'SET_ORIGINAL_POLICY_CHAIN', payload: [expect.objectContaining({ name: 'echo' })] })
    expect(store.dispatch).toHaveBeenCalledWith({ type: 'LOAD_CHAIN_SUCCESS', payload: [expect.objectContaining({ name: 'echo' })] })
  })

  it('Dispatches the correct update when REMOVE_POLICY_FROM_CHAIN', () => {
    void invoke({ type: 'REMOVE_POLICY_FROM_CHAIN', policy: chainPolicy })

    expect(store.dispatch).toHaveBeenCalledWith(updatePolicyChain([]))
  })

  it('Dispatches the correct update when UPDATE_POLICY_IN_CHAIN', () => {
    void invoke({ type: 'UPDATE_POLICY_IN_CHAIN', policyConfig: chainPolicy })

    expect(store.dispatch).toHaveBeenCalledWith(updatePolicyChain([chainPolicy]))
  })
})

describe('#findRegistryPolicy', () => {
  it('should find the policy with same name and version', () => {
    const storedPolicy = { name: 'some policy', version: '3' } as PolicyConfig
    const registry = [
      { name: 'some policy', version: '1' },
      { name: 'other policy', version: '1' },
      storedPolicy
    ] as RegistryPolicy[]

    expect(findRegistryPolicy(registry, storedPolicy)).toBe(storedPolicy)
  })
})

describe('#convertToChainPolicy', () => {
  it('should create a ChainPolicy', () => {
    expect(convertToChainPolicy(registryPolicy, policyConfig)).toMatchObject({
      name: 'name',
      configuration: {},
      version: '1',
      $schema: '{}',
      description: ['description'],
      summary: 'summary',
      humanName: 'Mr. Human',
      enabled: false,
      data: {},
      removable: true,
      uuid: expect.any(String)
    })
  })

  it('should create a ChainPolicy with random UUID', () => {
    const uuid = 'random_uuid'
    jest.spyOn(utils, 'generateGuid').mockReturnValueOnce(uuid)

    expect(convertToChainPolicy(registryPolicy, policyConfig).uuid).toBe(uuid)
  })

  it('should create a removable ChainPolicy unless PolicyConfig is apicast', () => {
    const noApicastPolicyConfig: PolicyConfig = {
      ...policyConfig,
      name: 'no_apicast'
    }
    expect(convertToChainPolicy(registryPolicy, noApicastPolicyConfig).removable).toEqual(true)

    const apicastPolicyConfig: PolicyConfig = {
      ...policyConfig,
      name: 'apicast'
    }
    expect(convertToChainPolicy(registryPolicy, apicastPolicyConfig).removable).toEqual(false)
  })
})

describe('#removePolicy', () => {
  it('should return the chain without a policy', () => {
    const policy = { uuid: '3' } as ChainPolicy
    const chain = [
      { uuid: '1' },
      { uuid: '2' },
      policy
    ] as ChainPolicy[]

    expect(removePolicy(chain, policy)).toEqual(chain.slice(0, 2))
  })
})

describe('#updatePolicy', () => {
  it('should return the chain without a policy', () => {
    const updatedPolicy = { uuid: '2', name: 'updated' } as ChainPolicy
    const chain = [
      { uuid: '1', name: '1' },
      { uuid: '2', name: '2' }
    ] as ChainPolicy[]

    expect(updatePolicy(chain, updatedPolicy)).toEqual([
      { uuid: '1', name: '1' },
      updatedPolicy
    ])
  })
})

describe('#loadChain', () => {
  const registry = [{
    name: 'policy_a',
    configuration: {},
    version: '1',
    $schema: '{}',
    description: ['description'],
    summary: 'summary',
    data: undefined,
    humanName: 'Policy A'
  }, {
    name: 'policy_b',
    configuration: {},
    version: '1',
    $schema: '{}',
    description: ['description'],
    summary: 'summary',
    data: undefined,
    humanName: 'Policy B'
  }]

  const dispatch = jest.fn()

  beforeEach(() => { dispatch.mockReset() })

  it('should find PolicyConfigs in a given registry and convert it to ChainPolicy', () => {
    const policiesConfig = [{
      name: 'policy_a',
      configuration: {},
      version: '1',
      enabled: false
    }] as PolicyConfig[]

    const res = {
      name: 'policy_a',
      configuration: {},
      version: '1',
      $schema: '{}',
      description: ['description'],
      summary: 'summary',
      humanName: 'Policy A',
      enabled: false,
      data: {},
      removable: true,
      uuid: expect.any(String)
    }

    loadChain({ registry, policiesConfig, dispatch })

    expect(dispatch).toHaveBeenNthCalledWith(1, { type: 'SET_ORIGINAL_POLICY_CHAIN', payload: [res] })
    expect(dispatch).toHaveBeenNthCalledWith(2, { type: 'LOAD_CHAIN_SUCCESS', payload: [res] })
  })

  it('should dispatch an error for every policy not found', () => {
    const wrongPolicyConfig = [
      { name: 'wrong name', version: '1' }
    ] as PolicyConfig[]

    loadChain({ registry, policiesConfig: wrongPolicyConfig, dispatch })

    expect(dispatch).toHaveBeenNthCalledWith(1, { type: 'LOAD_CHAIN_ERROR', payload: {} })
    expect(dispatch).toHaveBeenNthCalledWith(2, { type: 'SET_ORIGINAL_POLICY_CHAIN', payload: [] })
    expect(dispatch).toHaveBeenNthCalledWith(3, { type: 'LOAD_CHAIN_SUCCESS', payload: [] })
  })
})
