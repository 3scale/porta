// @flow

import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es7/array'
import 'core-js/es7/object'
import 'whatwg-fetch'

import React from 'react'

import Root from 'Policies/components/Root'
import configureStore from 'Policies/store/configureStore'
import { initialState } from 'Policies/reducers/initialState'
import { actions } from 'Policies/actions/index'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { RegistryPolicy, PolicyConfig } from 'Policies/types'

import 'Policies/styles/policies.scss'

type PoliciesProps = {
  registry: RegistryPolicy[],
  chain: PolicyConfig[],
  serviceId: string
}

const PoliciesWrapper = ({registry, chain, serviceId}: PoliciesProps, elementId: string) => {
  const store = configureStore(initialState)
  store.dispatch(actions.populatePolicies(serviceId, chain, registry))

  return createReactWrapper(<Root store={store} />, elementId)
}

export { PoliciesWrapper }
