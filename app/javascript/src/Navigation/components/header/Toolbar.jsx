import React from 'react'
import { Toolbar as PFToolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import AccountSettings from 'Navigation/components/header/AccountSettings'
import Documentation from 'Navigation/components/header/Documentation'

class Toolbar extends React.Component {
  getAccountSettingsProps () {
    return {
      accountSettingsLink: this.props.toolbarProps.accountSettingsLink,
      accountSettingsClass: this.props.toolbarProps.accountSettingsClass
    }
  }
  getDocsProps () {
    return {
      docsLink: this.props.docsProps.docsLink,
      isSaas: this.props.docsProps.isSaas,
      docsLinksClass: this.props.docsProps.docsLinksClass,
      customerPortalLink: this.props.docsProps.customerPortalLink,
      apiDocsLink: this.props.docsProps.apiDocsLink,
      liquidReferenceLink: this.props.docsProps.liquidReferenceLink,
      whatIsNewLink: this.props.docsProps.whatIsNewLink
    }
  }
  render () {
    return (
      <PFToolbar>
        <ToolbarGroup>
          <ToolbarItem>
            <AccountSettings {...this.getAccountSettingsProps()}/>
          </ToolbarItem>
          <ToolbarItem>
            <Documentation {...this.getDocsProps()}/>
          </ToolbarItem>
        </ToolbarGroup>
      </PFToolbar>
    )
  }
}

export default Toolbar
