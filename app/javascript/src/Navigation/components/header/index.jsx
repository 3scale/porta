import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import Avatar from 'Navigation/components/header/Avatar'
import Toolbar from 'Navigation/components/header/Toolbar'
import Brand from 'Navigation/components/header/Brand'

const getToolbarProps = (props) => {
  return {
    accountSettingsLink: props.accountSettingsLink,
    accountSettingsClass: props.accountSettingsClass
  }
}

const getDocsProps = (props) => {
  return {
    docsLink: props.docsLink,
    isSaas: props.isSaas,
    docsLinksClass: props.docsLinksClass,
    customerPortalLink: props.customerPortalLink,
    apiDocsLink: props.apiDocsLink,
    liquidReferenceLink: props.liquidReferenceLink,
    whatIsNewLink: props.whatIsNewLink
  }
}

const getAvatarProps = (props) => {
  return {
    avatarLinkClass: props.avatarLinkClass,
    avatarLink: props.avatarLink,
    impersonated: props.impersonated,
    accountName: props.accountName,
    displayName: props.displayName,
    logoutPath: props.logoutPath,
    username: props.username
  }
}

const getLogoProps = (props) => {
  return {
    href: props.href,
    target: '_self',
    title: 'Dashboard',
    className: `Header-link ${props.classHeaderWithLogo}`
  }
}

const Header = (props) => (
  <PageHeader
    logo={<Brand/>}
    logoProps = {getLogoProps(props)}
    toolbar = {<Toolbar toolbarProps={getToolbarProps(props)} docsProps={getDocsProps(props)}/>}
    avatar = {<Avatar {...getAvatarProps(props)}/>}/>
)

export default Header
