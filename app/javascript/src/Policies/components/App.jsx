/* eslint-disable import/no-named-as-default */
import React from 'react'
import PoliciesWidget from './PoliciesWidget'

// This is a class-based component because the current
// version of hot reloading won't hot reload a stateless
// component at the top-level.

class App extends React.Component {
  render () {
    const {store} = this.props

    return (
      <div>
        <PoliciesWidget store={store} />
      </div>
    )
  }
}

export default App
