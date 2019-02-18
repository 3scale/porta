import React from 'react'
class SimpleAvatar extends React.Component {
  // Values (class, link...) are hardcoded, check with app/views/shared/provider/_header.html.slim
  render () {
    return (
      <div className="PopNavigation PopNavigation--session">
        <a className="PopNavigation-trigger u-toggler" href="#session-menu" title="Session">
          <i className="fa fa-user "></i>
        </a>
        <ul className="PopNavigation-list u-toggleable" id="session-menu">
          <li className="PopNavigation-listItem">
            <p className="PopNavigation-info">Signed in to Provider Name as admin.</p>
            <a className="PopNavigation-link" title="Sign Out admin" href="/p/logout">
              <i className="fa fa-times fa-fw"></i> Sign Out
            </a>
          </li>
        </ul>
      </div>
    )
  }
}

export default SimpleAvatar
