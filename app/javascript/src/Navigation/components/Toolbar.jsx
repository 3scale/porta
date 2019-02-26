import React from 'react'
import { Toolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import AccountSettingsMenu from 'Navigation/components/AccountSettingsMenu'
import DocumentationItemMenu from 'Navigation/components/Documentation'

// TODO: Remove this hack
const divStyle = {
  display: 'none'
}

class SimpleToolbar extends React.Component {
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
      <Toolbar>
        <ToolbarGroup>
          <ToolbarItem>
            <AccountSettingsMenu {...this.getAccountSettingsProps()}/>
            <div className="username" style={divStyle}>admin</div>
          </ToolbarItem>
          <ToolbarItem>
            <DocumentationItemMenu {...this.getDocsProps()}/>
          </ToolbarItem>
        </ToolbarGroup>
      </Toolbar>
    )
  }
}

export default SimpleToolbar
