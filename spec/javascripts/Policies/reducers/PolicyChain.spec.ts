import ChainReducer from 'Policies/reducers/PolicyChain'
import { initialState } from 'Policies/reducers/initialState'
import { ChainPolicy } from 'Policies/types'

const policy00 = { $schema: '', uuid: '0', humanName: 'Headers', name: 'headers', description: ['Headers'], version: '1.0.0', configuration: {}, enabled: true, removable: true, summary: '', id: '666', data: {} }
const policy01 = { $schema: '', uuid: '1', humanName: 'CORS', name: 'cors', description: ['CORS'], version: '1.0.0', configuration: {}, removable: true, summary: '', enabled: true, id: '007', data: {} }
const chain: ChainPolicy[] = [policy00, policy01]

describe('ChainReducer', () => {
  it('should return the initial state', () => {
    expect(ChainReducer(undefined, { type: 'FOO' })).toEqual(initialState.chain)
  })

  it('should return the updated state', () => {
    expect(ChainReducer([], { type: 'FETCH_CHAIN_SUCCESS', payload: chain })).toEqual([...[], ...chain])
  })
})
