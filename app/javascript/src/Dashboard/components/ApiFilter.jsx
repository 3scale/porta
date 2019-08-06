// @flow

import 'raf/polyfill'
import 'core-js/es6/map'
import 'core-js/es6/set'
import 'core-js/es6/array'

import React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'

import 'Dashboard/styles/dashboard.scss'

import type { Api } from 'Types'

type Props = {
  apis: Api[],
  placeholder?: string,
  displayApis: Api[] => void
}

const ApiFilter = ({ apis, placeholder = 'All APIs', displayApis }: Props) => {
  const onInputChange = event => {
    const filterQuery = event.target.value.toLowerCase()
    const displayedApis = apis.filter(api => api.name.toLowerCase().indexOf(filterQuery) !== -1)

    displayApis(displayedApis)
  }

  return (
    <div className="ApiFilter">
      <input
        onChange={onInputChange}
        type="search"
        placeholder={placeholder}
      />
      <span className="fa fa-search" />
    </div>
  )
}

const ApiFilterWrapper = (props: Props, containerId: string) => createReactWrapper(<ApiFilter {...props} />, containerId)

export { ApiFilter, ApiFilterWrapper }
