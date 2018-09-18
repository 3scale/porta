import PolicyConfigReducer from '../reducers/PolicyConfig'
import { initialState } from './initialState'

const schema = {
  properties: {
    status: {
      type: 'integer',
      description: 'HTTP status code to be returned'
    }
  }
}

describe('PolicyConfig Reducer', () => {
  it('should return the initial state', () => {
    expect(PolicyConfigReducer(undefined, {})).toEqual(initialState.policyConfig)
  })

  it('should return the updated state when updating the config', () => {
    const newConfig = {
      $schema: '',
      schema,
      name: 'echo',
      humanName: 'Echo',
      configuration: {},
      id: '007',
      version: 'builtin',
      summary: '',
      description: 'Echo policy',
      enabled: true,
      removable: true,
      uuid: ''
    }
    expect(PolicyConfigReducer(initialState.policyConfig, { type: 'UPDATE_POLICY_CONFIG', policyConfig: newConfig }))
      .toEqual(newConfig)
  })
})
