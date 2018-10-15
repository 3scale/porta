// TODO: @flow
// TODO: test
import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es6/array'
import React from 'react'
import { render } from 'react-dom'
import { ApiSearch } from './ApiSearch'
import getActiveMenuTitle from '../utils/getActiveMenuTitle'

const AUDIENCE_PATH = '/buyers/accounts'

const ContextSelector = ({ apis, currentApi, activeMenu }) => (
  <div className="PopNavigation PopNavigation--context">
    <a className="PopNavigation-trigger u-toggler" href="#context-menu" title="Context Selector">
      <span> {getActiveMenuTitle(activeMenu, currentApi)} <i className='fa fa-chevron-down' /></span>
    </a>
    <ul id="context-menu" className="PopNavigation-list u-toggleable">
      <li className="PopNavigation-listItem">
        <a className="PopNavigation-link" href={AUDIENCE_PATH}>Audience</a>
      </li>
      {apis.length > 1 ? <ApiSearch apis={apis} /> : null}
    </ul>
  </div>
)

const ContextSelectorWrapper = (props, element) => {
  render(
    <ContextSelector {...props} />,
    document.getElementById(element)
  )
}

export { ContextSelector, ContextSelectorWrapper }
