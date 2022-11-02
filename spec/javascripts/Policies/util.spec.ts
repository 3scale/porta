import { createReducer, generateGuid, isNotApicastPolicy, isPolicyChainChanged } from 'Policies/util'

const policy00 = { $schema: '', uuid: '0', humanName: 'Headers', name: 'headers', description: ['Headers'], version: '1.0.0', configuration: {}, enabled: true, removable: true, summary: '', id: '666', data: {} }
const policy01 = { $schema: '', uuid: '1', humanName: 'CORS', name: 'cors', description: ['CORS'], version: '1.0.0', configuration: {}, removable: true, summary: '', enabled: true, id: '007', data: {} }

describe('isPolicyChainChanged', () => {
  const chain = [policy00]

  it('should detect when chain did not changed', () => {
    const newChain = [...[], ...chain]
    const changed = isPolicyChainChanged(chain, newChain)

    expect(changed).toEqual(false)
  })

  it('should detect a change when a new policy is added', () => {
    const newChain = [...chain, policy01]
    const changed = isPolicyChainChanged(newChain, chain)

    expect(changed).toEqual(true)
  })

  it('should detect a change when policies are rearranged', () => {
    const changed = isPolicyChainChanged([policy00, policy01], [policy01, policy00])

    expect(changed).toEqual(true)
  })

  it('should detect a change when a policy is updated', () => {
    const newChain = [{ ...policy00, data: { allow_origin: '123 123 123' } }]
    const changed = isPolicyChainChanged(newChain, chain)

    expect(changed).toEqual(true)
  })
})

describe('isNotApicastPolicy', () => {
  it('should detect if an apicast policy', () => {
    const apicastPolicy = { ...policy00, name: 'apicast' }
    expect(isNotApicastPolicy(apicastPolicy)).toEqual(false)
  })

  it('should detect if not an apicast policy', () => {
    const otherPolicy = { ...policy00, name: 'any-but-apicast' }
    expect(isNotApicastPolicy(otherPolicy)).toEqual(true)
  })
})

describe('createReducer', () => {
  it('should create a reducer', () => {
    const initialState: Record<string, any> = {}
    const handlers: Record<string, any> = {}
    const reducer = createReducer(initialState, handlers)

    expect(reducer).not.toBeUndefined()
  })
})

describe('generateGuid', () => {
  const regex = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/

  it('should generate a valid uuid', () => {
    expect(generateGuid()).toMatch(regex)
  })

  it('should generate a different uuid each time', () => {
    expect(generateGuid()).not.toEqual(generateGuid())
  })
})
