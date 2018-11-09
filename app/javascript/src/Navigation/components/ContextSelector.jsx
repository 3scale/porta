// TODO: @flow
// TODO: test
import 'core-js/modules/es6.set'
import 'core-js/modules/es6.map'
import 'core-js/es6/array'
import React from 'react'
import { render } from 'react-dom'
import { ActiveMenuTitle } from './ActiveMenuTitle'

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

  getClassNamesForMenu (menu) {
    const { activeMenu } = this.props

    if (menu === 'dashboard' && activeMenu === 'dashboard' ||
      menu === 'audience' && (['buyers', 'finance', 'cms', 'site'].indexOf(activeMenu) !== -1)) {
      return 'PopNavigation-link current-context'
    }

    return 'PopNavigation-link'
  }

  getClassNamesForService (service) {
    const { activeMenu, currentApi } = this.props
    let classNames = 'PopNavigation-link'

    if (['serviceadmin', 'monitoring'].indexOf(activeMenu) !== -1 &&
      service.id === currentApi.service.id) {
      classNames += ' current-context'
    }

    if (!service.link) {
      classNames += ' unauthorized'
    }

    return classNames
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
        <a className={this.getClassNamesForService(service)} href={service.link}>
          <i className="fa fa-puzzle-piece" />{service.name}
        </a>
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
          <ActiveMenuTitle currentApi={currentApi} activeMenu={activeMenu} />
        </a>
        <ul id="context-menu" className="PopNavigation-list u-toggleable">
          <li className="PopNavigation-listItem">
            <a className={this.getClassNamesForMenu('dashboard')} href={DASHBOARD_PATH}>
              <i className='fa fa-home' />Dashboard
            </a>
          </li>
          {audienceLink ? (
            <li className="PopNavigation-listItem">
              <a className={this.getClassNamesForMenu('audience')} href={audienceLink}>
                <i className='fa fa-bullseye' />Audience
              </a>
            </li>
          ) : null}
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
