// TODO: @flow
// TODO: test
import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es6/array'

import React from 'react'
import { render } from 'react-dom'

import '../styles/dashboard.scss'

const ApiFilter = ({ apis, displayApis }) => {
  const onInputChange = event => {
    const filterQuery = event.target.value.toLowerCase()
    const displayedApis = apis.filter(api => api.service.name.toLowerCase().indexOf(filterQuery) !== -1)

    displayApis(displayedApis)
  }

  return (
    <div className="ApiFilter">
      <input
        onChange={onInputChange}
        type="search"
        placeholder="All API's"
      />
      <span className="fa fa-search" />
    </div>
  )
}

const ApiFilterWrapper = (props, element) => render(
  <ApiFilter {...props} />,
  document.getElementById(element)
)

export { ApiFilter, ApiFilterWrapper }
