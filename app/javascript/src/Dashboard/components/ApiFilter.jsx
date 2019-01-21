// @flow

import 'raf/polyfill'
import 'core-js/es6/map'
import 'core-js/es6/set'
import 'core-js/es6/array'

import React from 'react'
import { render } from 'react-dom'

import 'Dashboard/styles/dashboard.scss'

import type { Api } from 'Types'

type Props = {
  apis: Api[],
  displayApis: Api[] => void
}

const ApiFilter = ({ apis, displayApis }: Props) => {
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
        placeholder="All APIs"
      />
      <span className="fa fa-search" />
    </div>
  )
}

const ApiFilterWrapper = (props: Props, element: string) => {
  const container = document.getElementById(element)
  if (container == null) {
    throw new Error(`${element} is not part of the DOM`)
  }
  render(<ApiFilter {...props} />, container)
}

export { ApiFilter, ApiFilterWrapper }
