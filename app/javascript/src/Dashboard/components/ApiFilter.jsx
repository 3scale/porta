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
  apis: $ReadOnlyArray<Api>,
  domClass: string,
  placeholder?: string
}

const ApiFilter = ({ apis, domClass, placeholder = 'All APIs' }: Props) => {
  const onInputChange = event => {
    const filterQuery = event.target.value.toLowerCase()
    const displayedApis = apis.filter(api => api.name.toLowerCase().indexOf(filterQuery) !== -1)

    displayApis(displayedApis)
  }

  const displayApis = (filteredApis: Api[]) => {
    for (const {id} of apis) {
      const isFilteredApi = filteredApis.some(filteredApi => filteredApi.id === id)

      const el = document.getElementById(`${domClass}_${id}`)
      if (el) {
        // Toggle method second argument not supported in IE11
        if (isFilteredApi) {
          el.classList.remove('hidden')
        } else {
          el.classList.add('hidden')
        }
      }
    }
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
