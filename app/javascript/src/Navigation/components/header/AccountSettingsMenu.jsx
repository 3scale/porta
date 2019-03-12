// @flow

import * as React from 'react'
import { ToolbarProps } from 'Navigation/components/header/types'

const AccountSettingsMenu = ({accountSettingsLink, accountSettingsClass}: {
  accountSettingsLink: ToolbarProps.accountSettingsLink,
  accountSettingsClass: ToolbarProps.accountSettingsLink}): React.Node => (
  <div className="PopNavigation PopNavigation--account">
    <a className={`PopNavigation-trigger ${accountSettingsClass}`} href={accountSettingsLink} title="Account Settings">
      <i className="fa fa-cog"></i>
    </a>
  </div>
)

export { AccountSettingsMenu }
