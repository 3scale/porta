import { policyChainMiddleware } from 'Policies/middleware/PolicyChain'
import { loadChainError, updatePolicyChain } from 'Policies/actions/PolicyChain'

const create = () => {
  const registry = [
    { name: 'echo', configuration: {}, summary: 'ECHO', description: 'ECHO', humanName: 'ECHO', version: 'builtin' }
  ]

  const chain = [{
    name: 'cors',
    configuration: {},
    summary: 'CORS',
    description: 'CORS',
    humanName: 'CORS',
    version: 'builtin',
    data: {},
    uuid: '007',
    enabled: true,
    removable: true
  }]

  const store = {
    getState: jest.fn(() => ({ registry, chain })),
    dispatch: jest.fn()
  }
  const next = jest.fn()
  const invoke = (action) => policyChainMiddleware(store)(next)(action)

  return { store, next, invoke }
}

describe('PolicyChain Middleware', () => {
  const { invoke, store, next } = create()

  beforeEach(() => {
    store.dispatch.mockClear()
  })

  it('Passes through non of middleware actions', () => {
    const action = { type: 'TEST' }
    invoke(action)

    expect(next).toHaveBeenCalledWith(action)
  })

  const validPolicy = { name: 'echo', version: 'builtin', configuration: { config: 'bond' }, enabled: true }
  const wrongPolicy = { name: 'foo', version: 'builtin', configuration: {}, enabled: true }

  it('Dispatches SET_ORIGINAL_POLICY_CHAIN and LOAD_CHAIN_SUCCESS action', () => {
    invoke({
      type: 'LOAD_CHAIN',
      policiesConfig: [validPolicy]
    })

    expect(store.dispatch.mock.calls[0][0].type).toBe('SET_ORIGINAL_POLICY_CHAIN')
    expect(store.dispatch.mock.calls[0][0].payload[0].data).toEqual(validPolicy.configuration)

    expect(store.dispatch.mock.calls[1][0].type).toBe('LOAD_CHAIN_SUCCESS')
    expect(store.dispatch.mock.calls[1][0].payload[0].data).toEqual(validPolicy.configuration)
  })

  it('Dispatches LOAD_CHAIN_ERROR action', () => {
    invoke({
      type: 'LOAD_CHAIN',
      policiesConfig: [wrongPolicy]
    })

    expect(store.dispatch).toHaveBeenCalledWith(loadChainError({}))
  })

  it('Dispatches SET_ORIGINAL_POLICY_CHAIN and LOAD_CHAIN_SUCCESS action only with valid policies', () => {
    invoke({
      type: 'LOAD_CHAIN',
      policiesConfig: [wrongPolicy, validPolicy]
    })

    expect(store.dispatch).toHaveBeenCalledWith(loadChainError({}))
    expect(store.dispatch).toHaveBeenCalledWith({ type: 'SET_ORIGINAL_POLICY_CHAIN', payload: [expect.objectContaining({ name: 'echo' })] })
    expect(store.dispatch).toHaveBeenCalledWith({ type: 'LOAD_CHAIN_SUCCESS', payload: [expect.objectContaining({ name: 'echo' })] })
  })

  it('Dispatches the correct update when REMOVE_POLICY_FROM_CHAIN', () => {
    invoke({
      type: 'REMOVE_POLICY_FROM_CHAIN',
      policy: {
        name: 'cors',
        configuration: {},
        summary: 'CORS',
        description: 'CORS',
        humanName: 'CORS',
        version: 'builtin',
        data: {},
        uuid: '007',
        enabled: true,
        removable: true
      }
    })

    expect(store.dispatch).toHaveBeenCalledWith(updatePolicyChain([]))
  })

  it('Dispatches the correct update when UPDATE_POLICY_IN_CHAIN', () => {
    const policyConfig = {
      name: 'cors',
      configuration: {},
      summary: 'CORS summary changed',
      description: 'CORS description changed',
      humanName: 'CORS changed',
      version: 'builtin',
      data: {},
      enabled: true,
      removable: true,
      uuid: '007'
    }

    invoke({ type: 'UPDATE_POLICY_IN_CHAIN', policyConfig })

    expect(store.dispatch).toHaveBeenCalledWith(updatePolicyChain([policyConfig]))
  })
})
