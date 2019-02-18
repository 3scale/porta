import React from 'react'
import { Toolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'

class SimpleToolbar extends React.Component {
  render () {
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
            { /* TODO: Extract to own component, check with app/views/shared/provider/_header.html.slim */ }
            <div className="PopNavigation PopNavigation--account">
              <a className="PopNavigation-trigger" href="/p/admin/account" title="Account Settings">
                <i className="fa fa-cog"></i>
              </a>
            </div>
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
