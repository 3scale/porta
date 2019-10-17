// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer, updateError, updateObject } from 'Policies/util'

import type { State, UIState } from 'Policies/types'
import type { UIComponentTransitionAction } from 'Policies/actions/UISettings'

function updateComponentTransition (state: State, action: UIComponentTransitionAction): State {
  return updateObject(state, {[action.hide]: false, [action.show]: true})
}

function updateRequestsCounter (number: number) {
  return function (state) {
    return updateObject(state, {requests: state.requests + number})
  }
}

// TODO: use combineReducers instead of createReducer
const UISettingsReducer = createReducer<UIState>(initialState.ui, {
  'UI_COMPONENT_TRANSITION': updateComponentTransition,
  'FETCH_CHAIN_ERROR': updateError,
  'FETCH_REGISTRY_ERROR': updateError,
  'API_REQUEST_START': updateRequestsCounter(1),
  'API_REQUEST_STOP': updateRequestsCounter(-1)
})

export default UISettingsReducer
