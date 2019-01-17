// @flow

import React from 'react'
import PoliciesWidget from 'Policies/components/PoliciesWidget'

// This is a class-based component because the current
// version of hot reloading won't hot reload a stateless
// component at the top-level.

type Props = {
  store: any
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
