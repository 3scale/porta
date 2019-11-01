// @flow

import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es7/array'
import 'core-js/es7/object'
import 'whatwg-fetch'

import React from 'react'
import { render } from 'react-dom'
import Root from 'Policies/components/Root'
import configureStore from 'Policies/store/configureStore'
import { initialState } from 'Policies/reducers/initialState'
import { actions } from 'Policies/actions/index'

import type { RawRegistry, StoredChainPolicy } from 'Policies/types'

import 'Policies/styles/policies.scss'

const Policies = (store, elementId) => {
  const element = document.getElementById(elementId)

  if (element === null) {
    console.error(`Policies cannot be rendered. Id '${elementId}' is not an element of the DOM.`)
    return
  }

  render(<Root store={store} />, element)
}

type InitPolicies = {
  registry: RawRegistry,
  chain: StoredChainPolicy[],
  serviceId: string
}

const initPolicies = ({registry, chain, serviceId}: InitPolicies, element: string) => {
  const store = configureStore(initialState)
  store.dispatch(actions.populatePolicies(serviceId, chain, registry))
  return Policies(store, element)
}

export { initPolicies }
