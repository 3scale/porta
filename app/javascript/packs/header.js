import React from 'react'
import { render } from 'react-dom'
import Header from '../src/Navigation/components/header'

document.addEventListener('DOMContentLoaded', () => {
  const divStyle = {
    display: 'none'
  }
  const headerElement = document.getElementById('user_widget')
  const props = {
    href: headerElement.dataset.href,
    classHeaderWithLogo: headerElement.dataset.classHeaderWithLogo,
    accountSettingsLink: headerElement.dataset.accountSettingsLink,
    accountSettingsClass: headerElement.dataset.accountSettingsClass,
    docsLink: headerElement.dataset.docsLink,
    isSaas: headerElement.dataset.isSaas,
    docsLinksClass: headerElement.dataset.docsLinksClass,
    customerPortalLink: headerElement.dataset.customerPortalLink,
    apiDocsLink: headerElement.dataset.apiDocsLink,
    liquidReferenceLink: headerElement.dataset.liquidReferenceLink,
    whatIsNewLink: headerElement.dataset.whatIsNewLink,
    avatarLink: headerElement.dataset.avatarLink,
    impersonated: headerElement.dataset.impersonated,
    accountName: headerElement.dataset.accountName,
    displayName: headerElement.dataset.displayName,
    logoutPath: headerElement.dataset.logoutPath,
    username: headerElement.dataset.username
  }
  const elem = <div>
    <Header {...props}/>
      {/* HACK of the month. See features/support/current_user.rb if you are hungry for reasons */}

    <div className="username" style={divStyle}>{headerElement.dataset.username}</div>
  </div>
  render(elem, headerElement)
})
