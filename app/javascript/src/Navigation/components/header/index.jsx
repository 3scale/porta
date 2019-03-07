import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import Avatar from 'Navigation/components/header/Avatar'
import Toolbar from 'Navigation/components/header/Toolbar'
import Brand from 'Navigation/components/header/Brand'

const getChildProps = (props, child) => {
  switch (child) {
    case 'toolbar':
      return {accountSettingsLink: props.accountSettingsLink, accountSettingsClass: props.accountSettingsClass}
    case 'docs':
      return {
        docsLink: props.docsLink,
        isSaas: props.isSaas,
        docsLinksClass: props.docsLinksClass,
        customerPortalLink: props.customerPortalLink,
        apiDocsLink: props.apiDocsLink,
        liquidReferenceLink: props.liquidReferenceLink,
        whatIsNewLink: props.whatIsNewLink
      }
    case 'avatar':
      return {
        avatarLinkClass: props.avatarLinkClass,
        avatarLink: props.avatarLink,
        impersonated: props.impersonated,
        accountName: props.accountName,
        displayName: props.displayName,
        logoutPath: props.logoutPath,
        username: props.username
      }
    case 'logo':
      return {href: props.href, target: '_self', title: 'Dashboard', className: `Header-link ${props.classHeaderWithLogo}`}
  }
}

const Header = (props) => (
  <PageHeader
    logo={<Brand/>}
    logoProps = {getChildProps(props, 'logo')}
    toolbar = {<Toolbar toolbarProps={getChildProps(props, 'toolbar')} docsProps={getChildProps(props, 'docs')}/>}
    avatar = {<Avatar {...getChildProps(props, 'avatar')}/>}/>
)

export default Header
