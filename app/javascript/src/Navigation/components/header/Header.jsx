import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import { Brand, SessionMenu, Toolbar } from 'Navigation/components/header'

const Header = ({logoProps, toolbarProps, docsProps, avatarProps}) => (
  <PageHeader
    logo = {<Brand/>}
    logoProps = {logoProps}
    toolbar = {<Toolbar toolbarProps={toolbarProps} docsProps={docsProps}/>}
    avatar = {<SessionMenu {...avatarProps}/>}/>
)

export { Header }
