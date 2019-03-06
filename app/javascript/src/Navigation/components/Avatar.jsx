import React from 'react'
import avatarImg from 'Navigation/images/img_avatar.svg'

const SimpleAvatar = ({avatarLink, impersonated, accountName, displayName, logoutPath, username}) => <div className="PopNavigation PopNavigation--session">
  <a className={`PopNavigation-trigger u-toggler ${impersonated}`} href="#session-menu" title="Session">
    <img src={avatarImg} width="30"/>
    {impersonated ? <i className="fa fa-bolt "></i> : null }
  </a>
  <ul className="PopNavigation-list u-toggleable" id="session-menu">
    <li className="PopNavigation-listItem">
      <p className="PopNavigation-info">
        { impersonated ? <i className="fa fa-bolt "></i> : null }
        { impersonated ? ' Impersonating a virtual admin user from ' : 'Signed in to '}
        { `${accountName} as ${displayName}.` }
      </p>
      <a id="sign-out-button" className="PopNavigation-link" title={`Sign Out ${username}`} href={logoutPath}>
        <i className="fa fa-times fa-fw"></i> Sign Out
      </a>
    </li>
  </ul>
</div>

export default SimpleAvatar
