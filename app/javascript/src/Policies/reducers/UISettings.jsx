// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateError, updateObject } from 'Policies/reducers/util'

import type { State } from 'Policies/types/State'
import type { UIComponentTransitionAction } from 'Policies/actions/UISettings'

function updateComponentTransition (state: State, action: UIComponentTransitionAction): State {
  return updateObject(state, {[action.hide]: false, [action.show]: true})
}

function updateRequestsCounter (number: number) {
  return function (state) {
    return updateObject(state, {requests: state.requests + number})
  }
}

const UISettingsReducer = createReducer(initialState.ui, {
  'UI_COMPONENT_TRANSITION': updateComponentTransition,
  'FETCH_CHAIN_ERROR': updateError,
  'FETCH_REGISTRY_ERROR': updateError,
  'API_REQUEST_START': updateRequestsCounter(1),
  'API_REQUEST_STOP': updateRequestsCounter(-1)
})

export default UISettingsReducer
