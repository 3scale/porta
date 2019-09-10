import React from 'react'
import {
  Nav,
  NavItem,
  NavList,
  NavVariants
} from '@patternfly/react-core'

class AudienceNav extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      activeItem: 0
    }
    this.onSelect = result => {
      this.setState({
        activeItem: result.itemId
      })
    }
  }

  render () {
    const { activeItem } = this.state
    return (
      <Nav onSelect={this.onSelect}>
        <NavList variant={NavVariants.tertiary}>
          {Array.apply(0, Array(5)).map(function (x, i) {
            const num = i + 1
            return <NavItem key={num} itemId={num} isActive={activeItem === num}>
              Tertiary nav item {num}
            </NavItem>
          })}
        </NavList>
      </Nav>
    )
  }
}

export {
  AudienceNav
}