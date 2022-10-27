import type { ChainPolicy } from 'Policies/types'
import type { Reducer } from 'redux'

function isNotApicastPolicy (policy: { name: string }): boolean {
  return policy.name !== 'apicast'
}

// TODO: refactor Action types, create a common interface and remove 'any' from here
function createReducer<S> (
  initialState: S,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any -- FIXME
  handlers: Record<string, (state: S, actions?: any) => S>
): Reducer<S> {
  // eslint-disable-next-line @typescript-eslint/default-param-last
  return function reducer (state = initialState, action) {
    if (Object.prototype.hasOwnProperty.call(handlers, action.type as string)) {
      return handlers[action.type as string](state, action)
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
