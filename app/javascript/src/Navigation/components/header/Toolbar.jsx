// @flow

import * as React from 'react'
import { Toolbar as PFToolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'
import { AccountSettingsMenu, DocumentationMenu } from 'Navigation/components/header/'
import { AccountSettingsProps, DocsProps } from 'Navigation/components/header/types'

const Toolbar = ({ accountSettingsProps, docsProps }: { accountSettingsProps: AccountSettingsProps, docsProps: DocsProps }): React.Node => <PFToolbar>
  <ToolbarGroup>
    <ToolbarItem>
      <AccountSettingsMenu {...accountSettingsProps}/>
    </ToolbarItem>
    <ToolbarItem>
      <DocumentationMenu {...docsProps}/>
    </ToolbarItem>
  </ToolbarGroup>
</PFToolbar>

export { Toolbar }
