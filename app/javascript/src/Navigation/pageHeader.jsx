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

    return (
      <PageHeader
        logo={<SimpleBrand/>}
        className = "Header"
        logoProps = {logoProps}
        toolbar = {<SimpleToolbar/>}
        avatar = {<Avatar/>}
      />
    )
  }
}

export default Header
