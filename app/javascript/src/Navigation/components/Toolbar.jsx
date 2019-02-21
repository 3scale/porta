import React from 'react'
import { Toolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import AccountSettingsMenu from 'Navigation/components/AccountSettingsMenu'

class SimpleToolbar extends React.Component {
  render () {
    const accountSettingsProps = {
      accountSettingsLink: this.props.toolbarProps.accountSettingsLink,
      accountSettingsClass: this.props.toolbarProps.accountSettingsClass
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
            { /* TODO: Extract to own component, check with app/views/shared/provider/_header.html.slim */ }
            <div className="PopNavigation PopNavigation--docs">
              <a className="PopNavigation-trigger u-toggler" href="#documentation-menu" title="Documentation">
                <i className="fa fa-question-circle "></i>
              </a>
            </div>
          </ToolbarItem>
        </ToolbarGroup>
      </Toolbar>
    )
  }
}

export default SimpleToolbar
