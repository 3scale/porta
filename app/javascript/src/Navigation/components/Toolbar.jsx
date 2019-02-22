import React from 'react'
import { Toolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import AccountSettingsMenu from 'Navigation/components/AccountSettingsMenu'
import DocumentationItemMenu from 'Navigation/components/Documentation'

class SimpleToolbar extends React.Component {
  render () {
    const accountSettingsProps = {
      accountSettingsLink: this.props.toolbarProps.accountSettingsLink,
      accountSettingsClass: this.props.toolbarProps.accountSettingsClass
    }
    const docsProps = {
      docsLink: this.props.docsProps.docsLink,
      isSaas: this.props.docsProps.isSaas,
      docsLinksClass: this.props.docsProps.docsLinksClass,
      customerPortalLink: this.props.docsProps.customerPortalLink,
      apiDocsLink: this.props.docsProps.apiDocsLink,
      liquidReferenceLink: this.props.docsProps.liquidReferenceLink,
      whatIsNewLink: this.props.docsProps.whatIsNewLink
    }
    return (
      <Toolbar>
        <ToolbarGroup>
          <ToolbarItem>
            { /* TODO: Use ContextSelector component, Navigation/components/ContextSelector.jsx */ }
            <div className="PopNavigation PopNavigation--context">
              <a className="PopNavigation-trigger u-toggler" href="#context-menu" title="Context Selector">
                <span className="ActiveMenuTitle">
                  <i className="fa fa-puzzle-piece"></i>API: API<i className="fa fa-chevron-down"></i>
                </span>
              </a>
            </div>
          </ToolbarItem>
        </ToolbarGroup>
        <ToolbarGroup>
          <ToolbarItem>
            <AccountSettingsMenu {...accountSettingsProps}/>
          </ToolbarItem>
          <ToolbarItem>
            <DocumentationItemMenu {...docsProps}/>
          </ToolbarItem>
        </ToolbarGroup>
      </Toolbar>
    )
  }
}

export default SimpleToolbar
