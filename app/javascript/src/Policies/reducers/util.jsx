// @flow

import type { State, StateSlice, UIState } from 'Policies/types/State'
import type { Action, FetchErrorAction } from 'Policies/types/index'

function updateObject (oldObject: Object, newValues: Object): Object {
  return {...oldObject, ...newValues}
}

function updateArray (oldArray: any, newValues: any): Array<any> {
  return Object.assign([], oldArray, newValues)
}

function createReducer (initialState: State | StateSlice, handlers: any) {
  return function reducer (state: StateSlice | State = initialState, action: Action) {
    if (handlers.hasOwnProperty(action.type)) {
      return handlers[action.type](state, action)
    } else {
      return state
    }
  }
}

// TODO: Work with Thomas on how showing the errors if any
function updateError (state: UIState, action: FetchErrorAction) {
  return updateObject(state, {error: action.payload})
}

function generateGuid (): string {
  function s4 () {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1)
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()
}

export {
  updateObject,
  updateArray,
  createReducer,
  updateError,
  generateGuid
}
