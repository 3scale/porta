// @flow

import React from 'react'
import 'core-js/es6/map'
import 'core-js/es6/set'

import 'Navigation/styles/ActiveMenuTitle.scss'

import type { Api, Menu } from 'Types'

type Props = {
  activeMenu: Menu,
  currentApi: Api
}

const ActiveMenuTitle = ({ activeMenu, currentApi }: Props) => {
  const getIconAndText: () => [string, string] = () => {
    switch (activeMenu) {
      case 'dashboard':
        return ['fa-home', 'Dashboard']

      case 'personal':
      case 'account':
        return ['fa-cog', 'Account Settings']

      case 'audience':
      case 'buyers':
      case 'finance':
      case 'cms':
      case 'site':
      case 'settings':
        return ['fa-bullseye', 'Audience']

      case 'apis':
      case 'applications':
      case 'active_docs':
        return ['fa-puzzle-piece', 'All APIs']

      case 'serviceadmin':
      case 'monitoring':
        return ['fa-puzzle-piece', `API: ${currentApi.service.name}`]

      default:
        return ['fa-puzzle-piece', 'Choose an API']
    }
  }

  const [icon, text] = getIconAndText()

  return (
    <span className="ActiveMenuTitle">
      <i className={`fa ${icon}`} />
      {text}
      <i className='fa fa-chevron-down' />
    </span>
  )
}

export { ActiveMenuTitle }
