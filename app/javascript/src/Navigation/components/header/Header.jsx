// @flow

import * as React from 'react'
import { PageHeader } from '@patternfly/react-core'
import { Brand, SessionMenu, Toolbar } from 'Navigation/components/header'
import { LogoProps, ToolbarProps, DocsProps, AvatarProps } from 'Navigation/components/header/types'

const Header = ({logoProps, toolbarProps, docsProps, avatarProps}: {
  logoProps: LogoProps, toolbarProps: ToolbarProps, docsProps: DocsProps, avatarProps: AvatarProps
}): React.Node => (
  <PageHeader
    logo = {<Brand/>}
    logoProps = {logoProps}
    toolbar = {<Toolbar toolbarProps={toolbarProps} docsProps={docsProps}/>}
    avatar = {<SessionMenu {...avatarProps}/>}/>
)

export { Header }
