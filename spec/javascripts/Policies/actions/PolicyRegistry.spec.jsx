import { fetchRegistry } from 'Policies/actions/PolicyRegistry'

describe('Policy Registry Actions', () => {
  it('should create an action to use the redux api middleware', () => {
    expect(fetchRegistry()).toEqual({
      '@@redux-api-middleware/RSAA': {
        credentials: 'same-origin',
        endpoint: '/admin/api/policies.json',
        method: 'GET',
        types: [
          {type: 'FETCH_REGISTRY_REQUEST'},
          {type: 'FETCH_REGISTRY_SUCCESS'},
          {type: 'FETCH_REGISTRY_ERROR'}
        ]
      }
    })
  })
})
