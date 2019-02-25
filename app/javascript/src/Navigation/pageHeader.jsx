import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import Avatar from 'Navigation/components/Avatar'
import SimpleToolbar from 'Navigation/components/Toolbar'
import SimpleBrand from 'Navigation/components/Brand'

class Header extends React.Component {
  constructor (props) {
    super(props)

    this.logoProps = {
      href: this.props.href,
      target: '_self',
      title: 'Dashboard',
      className: `Header-link ${this.props.classHeaderWithLogo}`
    }

    this.toolbarProps = {
      accountSettingsLink: this.props.accountSettingsLink,
      accountSettingsClass: this.props.accountSettingsClass
    }

    this.docsProps = {
      docsLink: this.props.docsLink,
      isSaas: this.props.isSaas,
      docsLinksClass: this.props.docsLinksClass,
      customerPortalLink: this.props.customerPortalLink,
      apiDocsLink: this.props.apiDocsLink,
      liquidReferenceLink: this.props.liquidReferenceLink,
      whatIsNewLink: this.props.whatIsNewLink
    }

    this.avatarProps = {
      avatarLink: this.props.avatarLink,
      impersonated: this.props.impersonated,
      accountName: this.props.accountName,
      displayName: this.props.displayName,
      logoutPath: this.props.logoutPath,
      username: this.props.username
    }
  }

  render () {
    return (
      <PageHeader
        logo={<SimpleBrand/>}
        className = "Header"
        logoProps = {this.logoProps}
        toolbar = {<SimpleToolbar toolbarProps={this.toolbarProps} docsProps={this.docsProps}/>}
        avatar = {<Avatar {...this.avatarProps}/>}
      />
    )
  }
}

export default Header
