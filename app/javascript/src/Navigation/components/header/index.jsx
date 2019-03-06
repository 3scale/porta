import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import Avatar from 'Navigation/components/header/Avatar'
import Toolbar from 'Navigation/components/header/Toolbar'
import Brand from 'Navigation/components/header/Brand'

class Header extends React.Component {
  getToolbarProps () {
    return {
      accountSettingsLink: this.props.accountSettingsLink,
      accountSettingsClass: this.props.accountSettingsClass
    }
  }

  getDocsProps () {
    return {
      docsLink: this.props.docsLink,
      isSaas: this.props.isSaas,
      docsLinksClass: this.props.docsLinksClass,
      customerPortalLink: this.props.customerPortalLink,
      apiDocsLink: this.props.apiDocsLink,
      liquidReferenceLink: this.props.liquidReferenceLink,
      whatIsNewLink: this.props.whatIsNewLink
    }
  }

  getAvatarProps () {
    return {
      avatarLink: this.props.avatarLink,
      impersonated: this.props.impersonated,
      accountName: this.props.accountName,
      displayName: this.props.displayName,
      logoutPath: this.props.logoutPath,
      username: this.props.username
    }
  }

  getLogoProps () {
    return {
      href: this.props.href,
      target: '_self',
      title: 'Dashboard',
      className: `Header-link ${this.props.classHeaderWithLogo}`
    }
  }

  render () {
    return (
      <PageHeader
        logo={<Brand/>}
        logoProps = {this.getLogoProps()}
        toolbar = {<Toolbar toolbarProps={this.getToolbarProps()} docsProps={this.getDocsProps()}/>}
        avatar = {<Avatar {...this.getAvatarProps()}/>}/>
    )
  }
}

export default Header
