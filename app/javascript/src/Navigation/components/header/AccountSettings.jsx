import React from 'react'

const AccountSettings = ({accountSettingsLink, accountSettingsClass}) => (
  <div className="PopNavigation PopNavigation--account">
    <a className={`PopNavigation-trigger ${accountSettingsClass}`} href={accountSettingsLink} title="Account Settings">
      <i className="fa fa-cog"></i>
    </a>
  </div>
)

export default AccountSettings
