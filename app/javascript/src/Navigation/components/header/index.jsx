import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import Avatar from 'Navigation/components/header/Avatar'
import Toolbar from 'Navigation/components/header/Toolbar'
import Brand from 'Navigation/components/header/Brand'

const Header = ({logoProps, toolbarProps, docsProps, avatarProps}) => (
  <PageHeader
    logo={<Brand/>}
    logoProps = {logoProps}
    toolbar = {<Toolbar toolbarProps={toolbarProps} docsProps={docsProps}/>}
    avatar = {<Avatar {...avatarProps}/>}/>
)

export default Header
