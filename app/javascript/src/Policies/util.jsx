// @flow

import type { Reducer, UIState, FetchErrorAction, RawPolicy, RawRegistry, RegistryPolicy, ChainPolicy, IAction } from 'Policies/types'

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

function parsePolicies (registry: RawRegistry): Array<RegistryPolicy> {
  let policies: Array<RegistryPolicy> = []
  for (let key in registry) {
    registry[key].forEach(policy => policies.push(parsePolicy(key, policy)))
  }
  return policies
}

function parsePolicy (key: string, policy: RawPolicy): RegistryPolicy {
  return { ...policy, name: key, humanName: policy.name, data: {} }
}

function isPolicyChainChanged (chain: ChainPolicy[], originalChain: ChainPolicy[]) {
  if (originalChain.length !== chain.length) {
    return true
  }

  for (const policy of chain) {
    const originalPolicy = originalChain.find(p => p.uuid === policy.uuid)
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
  parsePolicies,
  parsePolicy,
  isPolicyChainChanged
}
