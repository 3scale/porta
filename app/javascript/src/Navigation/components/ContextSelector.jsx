// @flow

import 'raf/polyfill'
import 'core-js/es6/map'
import 'core-js/es6/set'
import 'core-js/es6/array'

import React from 'react'
import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'
import { createReactWrapper } from 'utilities/createReactWrapper'

import 'Navigation/styles/ContextSelector.scss'

import type { Api, Menu } from 'Types'

type Props = {
  apis: Api[],
  currentApi: Api,
  activeMenu: Menu,
  audienceLink: string,
  apiap?: boolean
}

type State = {
  filterQuery: string
}

const DASHBOARD_PATH = '/p/admin/dashboard'

class ContextSelector extends React.Component<Props, State> {
  state = {
    filterQuery: ''
  }

  onFilterChange (event: SyntheticInputEvent<HTMLInputElement>) {
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
          onChange={(e: SyntheticInputEvent<HTMLInputElement>) => this.onFilterChange(e)}
          type="search"
          className="docs-search-input"
          placeholder="Type the API name"
        />
      </li>
    )
  }

  getClassNamesForMenu (menu: Menu): string {
    const { activeMenu } = this.props

    const isDashboardSelected = menu === 'dashboard' && activeMenu === 'dashboard'
    const isAudienceSelected = menu === 'audience' && (['buyers', 'finance', 'cms', 'site'].indexOf(activeMenu) !== -1)

    if (isDashboardSelected || isAudienceSelected) {
      return 'PopNavigation-link current-context'
    }

    return 'PopNavigation-link'
  }

  getClassNamesForService (api: Api): string {
    const { activeMenu, currentApi } = this.props
    let classNames = 'PopNavigation-link'

    if (['serviceadmin', 'monitoring', 'backend_api'].indexOf(activeMenu) !== -1 &&
      `${api.type}${api.id}` === `${currentApi.type}${currentApi.id}`) {
      classNames += ' current-context'
    }

    if (!api.link) {
      classNames += ' unauthorized'
    }

    return classNames
  }

  renderOptions () {
    const { apis } = this.props
    const { filterQuery } = this.state
    const filteredApis = apis.filter(api => api.name.toLowerCase().indexOf(filterQuery) !== -1)

    if (filteredApis.length === 0) {
      return null
    }

    const displayedApis = filteredApis.map(api => (
      <li key={`${api.type}-${api.id}`} className="PopNavigation-listItem">
        <a className={this.getClassNamesForService(api)} href={api.link}>
          <i className={`fa ${api.type === 'backend' ? 'fa-puzzle-piece' : 'fa-gift'}`} />{api.name}
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
    const { currentApi, activeMenu, audienceLink, apiap } = this.props

    return (
      <div className="PopNavigation PopNavigation--context">
        <a className="PopNavigation-trigger u-toggler" href="#context-menu" title="Context Selector">
          <ActiveMenuTitle currentApi={currentApi} activeMenu={activeMenu} apiap={apiap}/>
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

const ContextSelectorWrapper = (props: Props, containerId: string) => createReactWrapper(<ContextSelector {...props} />, containerId)

export { ContextSelector, ContextSelectorWrapper }
