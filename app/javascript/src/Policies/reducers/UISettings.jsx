// @flow

import { initialState } from 'Policies/reducers/initialState'
import { createReducer } from 'Policies/util'

import type { UIState, FetchErrorAction } from 'Policies/types'
import type { UIComponentTransitionAction } from 'Policies/actions/UISettings'

function updateComponentTransition (state: UIState, action: UIComponentTransitionAction): UIState {
  // $FlowIgnore[invalid-computed-prop] hide and show are primitive literals
  return { ...state, [action.hide]: false, [action.show]: true }
}

function updateRequestsCounter (number: number) {
  return function (state: UIState): UIState {
    return { ...state, requests: state.requests + number }
  }
}

function updateError (state: UIState, action: FetchErrorAction) {
  return { ...state, error: action.payload }
}

// TODO: use combineReducers instead of createReducer
// $FlowFixMe[signature-verification-failure] State types are very complex for Flow
const UISettingsReducer = createReducer<UIState>(initialState.ui, {
  'UI_COMPONENT_TRANSITION': updateComponentTransition,
  'FETCH_CHAIN_ERROR': updateError,
  'FETCH_REGISTRY_ERROR': updateError,
  'API_REQUEST_START': updateRequestsCounter(1),
  'API_REQUEST_STOP': updateRequestsCounter(-1)
})

export default UISettingsReducer
