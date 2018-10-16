import ChainReducer from 'Policies/reducers/PolicyChain'

const headersChainPolicy = {humanName: 'Headers', name: 'headers', description: 'Headers', version: '1.0.0', configuration: {}, enabled: true, id: '666'}
const corsChainPolicy = {humanName: 'CORS', name: 'cors', description: 'CORS', version: '1.0.0', configuration: {}, enabled: true, id: '007'}
const chain = [headersChainPolicy, corsChainPolicy]

describe('ChainReducer', () => {
  it('should return the initial state', () => {
    expect(ChainReducer(undefined, {})).toEqual([])
  })

  it('should return the updated state', () => {
    expect(ChainReducer([], { type: 'FETCH_CHAIN_SUCCESS', payload: chain })).toEqual(Object.assign([], chain))
  })
})
