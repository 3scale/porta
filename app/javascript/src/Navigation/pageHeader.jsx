import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import Avatar from 'Navigation/components/Avatar'
import SimpleToolbar from 'Navigation/components/Toolbar'
import SimpleBrand from 'Navigation/components/Brand'

class Header extends React.Component {
  render () {
    const logoProps = {
      href: this.props.href,
      target: '_self',
      className: `Header-link ${this.props.classHeaderWithLogo}`
    }

    const toolbarProps = {
      accountSettingsLink: this.props.accountSettingsLink,
      accountSettingsClass: this.props.accountSettingsClass
    }

    const docsProps = {
      docsLink: this.props.docsLink,
      isSaas: this.props.isSaas,
      docsLinksClass: this.props.docsLinksClass,
      customerPortalLink: this.props.customerPortalLink,
      apiDocsLink: this.props.apiDocsLink,
      liquidReferenceLink: this.props.liquidReferenceLink,
      whatIsNewLink: this.props.whatIsNewLink
    }

    const avatarProps = {
      avatarLink: this.props.avatarLink,
      impersonated: this.props.impersonated,
      accountName: this.props.accountName,
      displayName: this.props.displayName,
      logoutPath: this.props.logoutPath,
      username: this.props.username
    }

    return (
      <PageHeader
        logo={<SimpleBrand/>}
        className = "Header"
        logoProps = {logoProps}
        toolbar = {<SimpleToolbar toolbarProps={toolbarProps} docsProps={docsProps}/>}
        avatar = {<Avatar {...avatarProps}/>}
      />
    )
  }
}

export default Header
