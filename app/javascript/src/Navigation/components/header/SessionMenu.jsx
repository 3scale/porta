// @flow

import * as React from 'react'
import { Avatar } from '@patternfly/react-core'
import avatarImg from 'Navigation/images/img_avatar.svg'
import { AvatarProps } from 'Navigation/components/header/types'

type SessionMenuProps = {
  avatarLinkClass: AvatarProps.avatarLinkClass,
  impersonated: AvatarProps.impersonated,
  accountName: AvatarProps.accountName,
  displayName: AvatarProps.displayName,
  logoutPath: AvatarProps.logoutPath,
  username: AvatarProps.username
}

const SessionMenu = ({avatarLinkClass, impersonated, accountName, displayName, logoutPath, username}: SessionMenuProps): React.Node => (
  <div className="PopNavigation PopNavigation--session">
    <a className={`PopNavigation-trigger u-toggler ${avatarLinkClass} pf-m-avatar-link`} href="#session-menu" title="Session">
      <Avatar src={avatarImg} className="pf-m-avatar-img"/>
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
)

export { SessionMenu }
