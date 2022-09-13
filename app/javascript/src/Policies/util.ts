import type { Reducer, ChainPolicy, IAction } from 'Policies/types'

function isNotApicastPolicy (
  policy: {
    name: string
  }
): boolean {
  return policy.name !== 'apicast'
}

// TODO: refactor Action types, create a common interface and remove 'any' from here
// eslint-disable-next-line flowtype/no-weak-types
function createReducer<S> (
  initialState: S,
  handlers: {
    [key: string]: (arg1: S, arg2?: any) => S
  }
): Reducer<S> {
  return function reducer (state: S | null | undefined = initialState, action: IAction) {
    if (handlers.hasOwnProperty(action.type)) {
      return handlers[action.type](state, action)
    }

    return state
  }
}

function generateGuid (): string {
  function s4 () {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1)
  }
  return `${s4()}${s4()}-${s4()}-${s4()}-${s4()}-${s4()}${s4()}${s4()}`
}

function isPolicyChainChanged (chain: ChainPolicy[], originalChain: ChainPolicy[]): boolean {
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
  isNotApicastPolicy,
  createReducer,
  generateGuid,
  isPolicyChainChanged
}
