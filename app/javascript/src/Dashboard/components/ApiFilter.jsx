// TODO: @flow
// TODO: test
import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es6/array'

import React, { Component } from 'react'
import { render } from 'react-dom'

import '../styles/dashboard.scss'

class ApiFilter extends Component {
  onInputChange (event) {
    const { apis, onApisFiltered } = this.props
    const filterQuery = event.target.value.toLowerCase()
    const displayedApis = apis.filter(api => api.service.name.toLowerCase().indexOf(filterQuery) !== -1)

    console.log(displayedApis)
    onApisFiltered(apis, displayedApis)
  }

  render () {
    return (
      <div className="ApiFilter">
        <input
          onChange={e => this.onInputChange(e)}
          type="search"
          placeholder="All API's"
        />
        <span className="fa fa-search" />
      </div>
    )
  }
}

const ApiFilterWrapper = (props, element) => render(
  <ApiFilter {...props} />,
  document.getElementById(element)
)

export { ApiFilterWrapper as ApiFilter }
