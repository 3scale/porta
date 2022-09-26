import RegistryReducer from 'Policies/reducers/PolicyRegistry'
import { initialState } from 'Policies/reducers/initialState'
import { RegistryPolicy } from 'Policies/types'

const registry: RegistryPolicy[] = [{
  $schema: 'http://apicast.io/policy-v1/schema#manifest',
  name: 'cors',
  humanName: 'CORS',
  summary: 'CORS Summary',
  description: 'CORS Description',
  version: 'builtin',
  configuration: {}
}]

describe('RegistryReducer', () => {
  it('should return the initial state', () => {
    expect(RegistryReducer(undefined, { type: 'FOO' })).toEqual(initialState.registry)
  })

  it('should return the updated state', () => {
    const action = { type: 'FETCH_REGISTRY_SUCCESS', payload: registry }
    expect(RegistryReducer([], action)).toEqual([...registry, ...[]])
  })
})
