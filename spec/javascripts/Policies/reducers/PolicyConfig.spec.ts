import PolicyConfigReducer from 'Policies/reducers/PolicyConfig'
import { initialState } from 'Policies/reducers/initialState'

import type { ChainPolicy } from 'Policies/types'

const schema = {
  properties: {
    status: {
      type: 'integer',
      description: 'HTTP status code to be returned'
    }
  }
}

describe('PolicyConfigReducer', () => {
  it('should return the initial state', () => {
    expect(PolicyConfigReducer(undefined, { type: 'FOO' })).toEqual(initialState.policyConfig)
  })

  it('should return the updated state when updating the config', () => {
    const newConfig: ChainPolicy = {
      $schema: '',
      schema,
      name: 'echo',
      humanName: 'Echo',
      configuration: {},
      version: 'builtin',
      summary: '',
      description: ['Echo policy'],
      enabled: true,
      removable: true,
      uuid: ''
    }
    expect(PolicyConfigReducer(initialState.policyConfig, { type: 'UPDATE_POLICY_CONFIG', policy: newConfig }))
      .toEqual(newConfig)
  })
})
