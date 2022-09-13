import { createStore, compose, applyMiddleware } from 'redux'
import reduxImmutableStateInvariant from 'redux-immutable-state-invariant'
import thunk from 'redux-thunk'
import { apiMiddleware } from 'redux-api-middleware'
import { policyChainMiddleware } from 'Policies/middleware/PolicyChain'
import rootReducer from 'Policies/reducers'

import type { State, Store } from 'Policies/types'

function configureStoreProd (initialState: State): Store {
  const middlewares = [
    // Add other middleware on this line...

    // thunk middleware can also accept an extra argument to be passed to each thunk action
    // https://github.com/gaearon/redux-thunk#injecting-a-custom-argument
    thunk,
    apiMiddleware,
    policyChainMiddleware
  ]

  return createStore(rootReducer, initialState, compose(
    // $FlowIgnore[incompatible-variance]
    applyMiddleware(...middlewares)
  ))
}

function configureStoreDev (initialState: State): Store {
  const middlewares = [
    // Add other middleware on this line...

    // Redux middleware that spits an error on you when you try to mutate your state either inside a dispatch or between dispatches.
    reduxImmutableStateInvariant(),

    // thunk middleware can also accept an extra argument to be passed to each thunk action
    // https://github.com/gaearon/redux-thunk#injecting-a-custom-argument
    thunk,
    apiMiddleware,
    policyChainMiddleware
  ]

  const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose // add support for Redux dev tools

  const store = createStore(rootReducer, initialState, composeEnhancers(
    // $FlowIgnore[incompatible-variance]
    applyMiddleware(...middlewares)
  ))

  return store
}

const configureStore = process.env.NODE_ENV === 'production' ? configureStoreProd : configureStoreDev

export default configureStore
