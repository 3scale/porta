// @flow

import * as React from 'react'
import { Toolbar as PFToolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import { AccountSettingsMenu, DocumentationMenu } from 'Navigation/components/header/'
import { ToolbarProps, DocsProps } from 'Navigation/components/header/types'

const Toolbar = ({ toolbarProps, docsProps }: { toolbarProps: ToolbarProps, docsProps: DocsProps }): React.Node => <PFToolbar>
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
