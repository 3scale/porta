// @flow

import * as React from 'react'
import { PageHeader } from '@patternfly/react-core'
import { Brand, SessionMenu, Toolbar } from 'Navigation/components/header'
import { LogoProps, AccountSettingsProps, DocsProps, AvatarProps } from 'Navigation/components/header/types'

const Header = ({logoProps, accountSettingsProps, docsProps, avatarProps}: {
  logoProps: LogoProps, accountSettingsProps: AccountSettingsProps, docsProps: DocsProps, avatarProps: AvatarProps
}) => (
  <PageHeader
    logo = {<Brand/>}
    logoProps = {logoProps}
    toolbar = {<Toolbar accountSettingsProps={accountSettingsProps} docsProps={docsProps}/>}
    avatar = {<SessionMenu {...avatarProps}/>}/>
)

export { Header }
