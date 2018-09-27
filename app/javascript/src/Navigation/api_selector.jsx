// TODO: @flow
// TODO: test
import 'babel-polyfill'
import React, { Component } from 'react'
import { render } from 'react-dom'

const apiPathRoot = apiId => `/apiconfig/services/${apiId}/metrics`

const Suggestions = (props) => {
  const { apis } = props
  const options = apis.map((api, index) => (
    <li key={index} className="PopNavigation-listItem">
      <a className="PopNavigation-link" href={`${apiPathRoot(api.service.id)}`}>{api.service.name}</a>
    </li>
  ))
  return <ul className="PopNavigation-results">{options}</ul>
}

const searchBoxTitle = (api, controllerName) => {
  const title = (api && controllerName !== 'dashboards') ? `API: ${api.service.name.toUpperCase()}` : 'Jumpt to an API'
  return (<span> {title} <i className='fa fa-chevron-down'></i></span>)
}

class ApiSearch extends Component {
  constructor (props) {
    super(props)
    this.state = {
      displayedApis: props.apis
    }
  }

  searchHandler (event) {
    const searchQuery = event.target.value.toLowerCase()
    const displayedApis = this.props.apis.filter((api) => api.service.name.toLowerCase().indexOf(searchQuery) !== -1)
    this.setState({
      displayedApis
    })
  }

  render () {
    return (
      <div className="PopNavigation PopNavigation--context">
        <a className="PopNavigation-trigger u-toggler" href="#context-menu" title="Context Switcher">
          { searchBoxTitle(this.props.currentApi, this.props.controllerName) }
        </a>
        <ul id="context-menu" className="PopNavigation-list u-toggleable">
          <li className="PopNavigation-listItem">
            <div id="context-widget" className="nav-search-widget">
              <form className="docs-search" data-role="search">
                <a href="#" data-role="close" className="close-widget">x</a>
                <input
                  onChange={(e) => this.searchHandler(e)}
                  type="search"
                  className="docs-search-input"
                  placeholder="Type the API name"
                />
              </form>
            </div>
          </li>
          <li className="PopNavigation-listItem">
            <Suggestions apis={this.state.displayedApis} />
          </li>
        </ul>
      </div>
    )
  }
}

const ApiSelector = (props, element) => {
  render(
    <ApiSearch {...props} />,
    document.getElementById(element)
  )
}

export {
  ApiSelector
}
