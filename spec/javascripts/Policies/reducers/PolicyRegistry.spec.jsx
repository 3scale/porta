import RegistryReducer from 'Policies/reducers/PolicyRegistry'

const rawRegistry = {
  cors: [{
    $schema: 'http://apicast.io/policy-v1/schema#manifest',
    name: 'CORS',
    summary: 'CORS Summary',
    description: 'CORS Description',
    version: 'builtin',
    configuration: {}
  }]
}

describe('RegistryReducer', () => {
  it('should return the initial state', () => {
    expect(RegistryReducer(undefined, {})).toEqual([])
  })

  it('should return the updated state', () => {
    const action = {
      type: 'FETCH_REGISTRY_SUCCESS',
      payload: rawRegistry
    }
    expect(RegistryReducer([], action)).toEqual([{
      $schema: 'http://apicast.io/policy-v1/schema#manifest',
      name: 'cors',
      configuration: {},
      description: 'CORS Description',
      summary: 'CORS Summary',
      humanName: 'CORS',
      version: 'builtin',
      data: {}
    }])
  })
})
