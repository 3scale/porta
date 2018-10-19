// TODO: @flow
// TODO: test
import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es6/array'
import React from 'react'
import { render } from 'react-dom'
import getActiveMenuTitle from '../utils/getActiveMenuTitle'

import '../styles/ContextSelector.scss'

const DASHBOARD_PATH = '/p/admin/dashboard'

class ContextSelector extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      filterQuery: ''
    }
  }

  onFilterChange (event) {
    const filterQuery = event.target.value.toLowerCase()
    this.setState({ filterQuery })
  }

  renderInput () {
    const { apis = [] } = this.props

    if (apis.length < 2) {
      return null
    }

    return (
      <li className="PopNavigation-listItem nav-search-widget docs-search" id="context-widget">
        <input
          onChange={e => this.onFilterChange(e)}
          type="search"
          className="docs-search-input"
          placeholder="Type the API name"
        />
      </li>
    )
  }

  getClassNamesFor ({ menu, api }) {
    const { activeMenu, currentApi } = this.props

    if (menu === 'dashboard' && activeMenu === 'dashboard' ||
      menu === 'audience' && (['buyers', 'finance', 'cms', 'site'].indexOf(activeMenu) !== -1) ||
      api && (['serviceadmin', 'monitoring'].indexOf(activeMenu) !== -1) && api === currentApi.service.id) {
      return 'PopNavigation-link current-context'
    }

    return 'PopNavigation-link'
  }

  renderOptions () {
    const { apis } = this.props
    const { filterQuery } = this.state
    const filteredApis = apis.filter(api => api.service.name.toLowerCase().indexOf(filterQuery) !== -1)

    if (filteredApis.length === 0) {
      return null
    }

    const displayedApis = filteredApis.map(({ service }) => (
      <li key={service.id} className="PopNavigation-listItem">
        <a className={this.getClassNamesFor({ api: service.id })} href={service.link}>{service.name}</a>
      </li>
    ))

    return (
      <li className="PopNavigation-listItem">
        <ul className="PopNavigation-results">
          {displayedApis}
        </ul>
      </li>
    )
  }

  render () {
    const { currentApi, activeMenu, audienceLink } = this.props

    return (
      <div className="PopNavigation PopNavigation--context">
        <a className="PopNavigation-trigger u-toggler" href="#context-menu" title="Context Selector">
          <span> {getActiveMenuTitle(activeMenu, currentApi)} <i className='fa fa-chevron-down' /></span>
        </a>
        <ul id="context-menu" className="PopNavigation-list u-toggleable">
          <li className="PopNavigation-listItem">
            <a className={this.getClassNamesFor({ menu: 'dashboard' })} href={DASHBOARD_PATH}>Dashboard</a>
          </li>
          <li className="PopNavigation-listItem">
            <a className={this.getClassNamesFor({ menu: 'audience' })} href={audienceLink}>Audience</a>
          </li>
          {this.renderInput()}
          {this.renderOptions()}
        </ul>
      </div >
    )
  }
}

const ContextSelectorWrapper = (props, element) => {
  render(
    <ContextSelector {...props} />,
    document.getElementById(element)
  )
}

export { ContextSelector, ContextSelectorWrapper }
