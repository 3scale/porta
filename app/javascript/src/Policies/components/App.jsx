// @flow

import React from 'react'
import PoliciesWidget from 'Policies/components/PoliciesWidget'

import type { Store } from 'Policies/types'

// This is a class-based component because the current
// version of hot reloading won't hot reload a stateless
// component at the top-level.

type Props = {
  store: Store
}

class App extends React.Component<Props, {}> {
  render () {
    const { store } = this.props

    return (
      <div>
        <PoliciesWidget store={store} />
      </div>
    )
  }
}

export default App
