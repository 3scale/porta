import React from 'react'
import { render } from 'react-dom'
import Header from '../src/Navigation/pageHeader'

document.addEventListener('DOMContentLoaded', () => {
  const headerElement = document.getElementById('headerPF4')
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
  render(<Header {...props}/>, headerElement)
})
