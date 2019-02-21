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

    return (
      <PageHeader
        logo={<SimpleBrand/>}
        className = "Header"
        logoProps = {logoProps}
        toolbar = {<SimpleToolbar toolbarProps={toolbarProps}/>}
        avatar = {<Avatar/>}
      />
    )
  }
}

export default Header
