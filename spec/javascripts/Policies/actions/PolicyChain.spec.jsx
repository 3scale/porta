import { fetchChain } from 'Policies/actions/PolicyChain'

describe('Policy Chain Actions', () => {
  it('should create an action to use the redux api middleware', () => {
    expect(fetchChain('666')).toEqual({
      '@@redux-api-middleware/RSAA': {
        credentials: 'same-origin',
        endpoint: '/admin/api/services/666/proxy/policies.json',
        method: 'GET',
        types: [
          {type: 'FETCH_CHAIN_REQUEST'},
          {type: 'FETCH_CHAIN_SUCCESS'},
          {type: 'FETCH_CHAIN_ERROR'}
        ]
      }
    })
  })
})
