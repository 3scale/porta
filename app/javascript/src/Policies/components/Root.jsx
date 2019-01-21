// @flow

import React from 'react'
import PropTypes from 'prop-types'

import { Provider } from 'react-redux'

import App from 'Policies/components/App'

import type { Store } from 'Policies/types'

type Props = {
  store: Store
}

export default function Root (props: Props) {
  const { store } = props

  return (
    <Provider store={store}>
      <App store={store} />
    </Provider>
  )
}

Root.propTypes = {
  store: PropTypes.object.isRequired
}
