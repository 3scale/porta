// @flow

import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es7/array'
import 'core-js/es7/object'

import React from 'react'
import { render } from 'react-dom'
import { AppContainer } from 'react-hot-loader'
import Root from 'Policies/components/Root'
import configureStore from 'Policies/store/configureStore'
import { initialState } from 'Policies/reducers/initialState'
import { actions } from 'Policies/actions/index'

import type { RawRegistry, StoredChainPolicy } from 'Policies/types/Policies'

import 'Policies/styles/policies.scss'

const Policies = (store, elementId) => {
  const element = document.getElementById(elementId)

  if (element === null) {
    console.error(`Policies cannot be rendered. Id '${elementId}' is not an element of the DOM.`)
    return
  }

  render(
    <AppContainer>
      <Root store={store} />
    </AppContainer>,
    element
  )

  if (module.hot) {
    module.hot.accept('./components/Root', () => {
      const NewRoot = require('./components/Root').default
      render(
        <AppContainer>
          <NewRoot store={store} />
        </AppContainer>,
        element
      )
    })
  }
}

type InitPolicies = {
  element: string,
  registry: RawRegistry,
  chain: StoredChainPolicy[],
  serviceId: string
}

const initPolicies = ({element, registry, chain, serviceId}: InitPolicies) => {
  const store = configureStore(initialState)
  const policies = {chain, registry}
  store.dispatch(actions.populatePolicies(serviceId, policies))
  return Policies(store, element)
}

export default initPolicies
