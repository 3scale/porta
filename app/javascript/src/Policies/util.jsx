// @flow

import type { Reducer, UIState, FetchErrorAction, ChainPolicy, IAction } from 'Policies/types'

// Needs to be any, since it's a subset of T
// eslint-disable-next-line flowtype/no-weak-types
function updateObject<T> (oldObject: T, newValues: any): T {
  return {...oldObject, ...newValues}
}

function updateArray<T> (oldArray: Array<T>, newValues: Array<T>): Array<T> {
  // $FlowFixMe: it does return an array, flow types are incorrect here
  return Object.assign([], oldArray, newValues)
}

// TODO: refactor Action types, create a common interface and remove 'any' from here
// eslint-disable-next-line flowtype/no-weak-types
function createReducer<S> (initialState: S, handlers: {[string]: (S, any) => S}): Reducer<S> {
  return function reducer (state: S = initialState, action: IAction) {
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

function isPolicyChainChanged (chain: ChainPolicy[], originalChain: ChainPolicy[]) {
  const chainLength = chain.length
  if (originalChain.length !== chainLength) {
    return true
  }

  for (let i = 0; i < chainLength; i++) {
    const policy = chain[i]
    const originalPolicy = originalChain[i]
    if (JSON.stringify(policy) !== JSON.stringify(originalPolicy)) {
      return true
    }
  }

  return false
}

export {
  updateObject,
  updateArray,
  createReducer,
  updateError,
  generateGuid,
  isPolicyChainChanged
}
