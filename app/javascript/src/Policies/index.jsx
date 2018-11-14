/* eslint-disable import/default */
import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es7/array'
import 'core-js/es7/object'

import React from 'react'
import { render } from 'react-dom'
import { AppContainer } from 'react-hot-loader'
import Root from './components/Root'
import configureStore from './store/configureStore'
import { initialState } from './reducers/initialState'
import * as actions from './actions/index'

import './styles/policies.scss'

const Policies = (store, element) => {
  render(
    <AppContainer>
      <Root store={store} /* history={history} */ />
    </AppContainer>,
    document.getElementById(element)
  )

  if (module.hot) {
    module.hot.accept('./components/Root', () => {
      const NewRoot = require('./components/Root').default
      render(
        <AppContainer>
          <NewRoot store={store} /* history={history} */ />
        </AppContainer>,
        document.getElementById(element)
      )
    })
  }
}

const initPolicies = ({element, registry, chain, serviceId}) => {
  const store = configureStore(initialState)
  const policies = {chain, registry}
  store.dispatch(actions.populatePolicies(serviceId, policies))
  return Policies(store, element)
}

export default initPolicies
