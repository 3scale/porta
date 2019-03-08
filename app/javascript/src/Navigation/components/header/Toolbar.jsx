import React from 'react'
import { Toolbar as PFToolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import { AccountSettingsMenu, DocumentationMenu } from 'Navigation/components/header/'

const Toolbar = ({ toolbarProps, docsProps }) => <PFToolbar>
  <ToolbarGroup>
    <ToolbarItem>
      <AccountSettingsMenu {...toolbarProps}/>
    </ToolbarItem>
    <ToolbarItem>
      <DocumentationMenu {...docsProps}/>
    </ToolbarItem>
  </ToolbarGroup>
</PFToolbar>

export { Toolbar }
