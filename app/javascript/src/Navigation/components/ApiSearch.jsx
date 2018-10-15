import 'core-js/es6/array'
import React, { Component } from 'react'

const apiPathRoot = apiId => `/apiconfig/services/${apiId}/metrics`

class ApiSearch extends Component {

  constructor (props) {
    super(props)
    this.state = {
      displayedApis: props.apis
    }
  }

  filterApis (event) {
    const filterQuery = event.target.value.toLowerCase()
    const displayedApis = this.props.apis.filter(api => api.service.name.toLowerCase().indexOf(filterQuery) !== -1)
    this.setState({ displayedApis })
  }

  render () {
    const { displayedApis } = this.state

    const options = displayedApis.map(({ service }) => (
      <li key={service.id} className="PopNavigation-listItem">
        <a className="PopNavigation-link" href={apiPathRoot(service.id)}>{service.name}</a>
      </li>
    ))

    return (
      <React.Fragment>
        <li className="PopNavigation-listItem">
          <div id="context-widget" className="nav-search-widget">
            <form className="docs-search" data-role="search">
              <a href="#" data-role="close" className="close-widget">x</a>
              <input
                onChange={e => this.filterApis(e)}
                type="search"
                className="docs-search-input"
                placeholder="Type the API name"
              />
            </form>
          </div>
        </li>
        <li className="PopNavigation-listItem">
          <ul className="PopNavigation-results">{options}</ul>
        </li>
      </React.Fragment>
    )
  }
}

export { ApiSearch }
