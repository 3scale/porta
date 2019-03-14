import React from 'react'
import { render } from 'react-dom'
import { Header } from 'Navigation/components/header'

document.addEventListener('DOMContentLoaded', () => {
  const divStyle = {
    display: 'none'
  }
  const headerContainer = document.getElementById('user_widget')
  const props = {
    accountSettingsProps: {
      accountSettingsLink: headerContainer.dataset.accountSettingsLink,
      accountSettingsClass: headerContainer.dataset.accountSettingsClass
    },
    docsProps: {
      docsLink: headerContainer.dataset.docsLink,
      isSaas: headerContainer.dataset.isSaas,
      docsLinksClass: headerContainer.dataset.docsLinksClass,
      customerPortalLink: headerContainer.dataset.customerPortalLink,
      apiDocsLink: headerContainer.dataset.apiDocsLink,
      liquidReferenceLink: headerContainer.dataset.liquidReferenceLink,
      whatIsNewLink: headerContainer.dataset.whatIsNewLink
    },
    avatarProps: {
      avatarLinkClass: headerContainer.dataset.avatarLinkClass,
      impersonated: headerContainer.dataset.impersonated,
      accountName: headerContainer.dataset.accountName,
      displayName: headerContainer.dataset.displayName,
      logoutPath: headerContainer.dataset.logoutPath,
      username: headerContainer.dataset.username
    },
    logoProps: {
      href: headerContainer.dataset.href,
      title: 'Dashboard',
      target: '_self',
      className: `Header-link ${headerContainer.dataset.classHeaderWithLogo}`
    }
  }

  const elem = <div>
    <Header {...props}/>
    {/* HACK of the month. See features/support/current_user.rb if you are hungry for reasons */}
    <div className="username" style={divStyle}>{headerContainer.dataset.username}</div>
  </div>
  render(elem, headerContainer)
})
