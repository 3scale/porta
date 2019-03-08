import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import SessionMenu from 'Navigation/components/header/SessionMenu'
import Toolbar from 'Navigation/components/header/Toolbar'
import Brand from 'Navigation/components/header/Brand'

const Header = ({logoProps, toolbarProps, docsProps, avatarProps}) => (
  <PageHeader
    logo={<Brand/>}
    logoProps = {logoProps}
    toolbar = {<Toolbar toolbarProps={toolbarProps} docsProps={docsProps}/>}
    avatar = {<SessionMenu {...avatarProps}/>}/>
)

export default Header
