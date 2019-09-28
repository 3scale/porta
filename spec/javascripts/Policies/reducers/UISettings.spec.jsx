import UISettingsReducer from 'Policies/reducers/UISettings'
import { initialState } from 'Policies/reducers/initialState'

describe('UISettingsReducer', () => {
  it('should return the initial state', () => {
    expect(UISettingsReducer(undefined, {})).toEqual({
      'chain': true,
      'error': {},
      'policyConfig': false,
      'registry': false,
      'submitButtonEnabled': false,
      'requests': 0
    })
  })

  it('should return the updated state', () => {
    expect(UISettingsReducer(initialState.ui, { type: 'UI_COMPONENT_TRANSITION', hide: 'chain', show: 'registry' })).toEqual({
      chain: false,
      policyConfig: false,
      registry: true,
      requests: 0,
      submitButtonEnabled: false,
      error: {}
    })
  })

  it('should return the updated state slice when api call action was dispatched', () => {
    expect(UISettingsReducer(initialState.ui, { type: 'API_REQUEST_START' }).requests).toEqual(1)
  })
})
