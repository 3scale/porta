import React from 'react'
import { PageHeader } from '@patternfly/react-core'
import Avatar from 'Navigation/components/Avatar'
import SimpleToolbar from 'Navigation/components/Toolbar'

class Header extends React.Component {
  render () {
    const logoProps = {
      href: this.props.href,
      target: '_self',
      className: 'Header-link'
    }

    const logo = <div className="Header-logo Header-logo--withIcon"></div>

    return (
      <PageHeader
        logo={logo}
        className = "Header"
        logoProps = {logoProps}
        toolbar = {<SimpleToolbar/>}
        avatar = {<Avatar/>}
      />
    )
  }
}

export default Header
