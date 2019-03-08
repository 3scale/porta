import React from 'react'
import { Toolbar as PFToolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import { AccountSettingsMenu, DocumentationMenu } from 'Navigation/components/header/'

const getAccountSettingsProps = toolbarProps => {
  return {
    accountSettingsLink: toolbarProps.accountSettingsLink,
    accountSettingsClass: toolbarProps.accountSettingsClass
  }
}

const getDocsProps = docsProps => {
  return {
    docsLink: docsProps.docsLink,
    isSaas: docsProps.isSaas,
    docsLinksClass: docsProps.docsLinksClass,
    customerPortalLink: docsProps.customerPortalLink,
    apiDocsLink: docsProps.apiDocsLink,
    liquidReferenceLink: docsProps.liquidReferenceLink,
    whatIsNewLink: docsProps.whatIsNewLink
  }
}

const Toolbar = ({ toolbarProps, docsProps }) => <PFToolbar>
  <ToolbarGroup>
    <ToolbarItem>
      <AccountSettingsMenu {...getAccountSettingsProps(toolbarProps)}/>
    </ToolbarItem>
    <ToolbarItem>
      <DocumentationMenu {...getDocsProps(docsProps)}/>
    </ToolbarItem>
  </ToolbarGroup>
</PFToolbar>

export { Toolbar }
