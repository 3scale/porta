// TODO: @flow
// TODO: test
import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es6/array'

import React, { Component } from 'react'
import { render } from 'react-dom'

class ApiFilter extends Component {
  render () {
    return <h1 className='DashboardSection-title'>All APIs</h1>
  }
}

const ApiFilterWrapper = (props, element) => render(
  <ApiFilter {...props} />,
  document.getElementById(element)
)

export { ApiFilterWrapper as ApiFilter }
