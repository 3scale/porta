// @flow

import React from 'react'
import {
  Nav,
  NavExpandable,
  NavGroup,
  NavItem,
  NavList
} from '@patternfly/react-core'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Item = {
  id: string,
  title: string,
  path: ?string
}

type Section = Item & {
  items: ?Item[]
}

type Props = {
  sections: Section[],
  activeSection: ?string,
  activeItem: ?string
}

const VerticalNav = ({sections, activeSection, activeItem}: Props) => (
  <div className="pf-c-page__sidebar-body">
    <Nav id='mainmenu'>
      <NavList>
        {sections.map(({ id, title, path, items }) => {
          return items
            ? <NavSection title={title} isSectionActive={id === activeSection} activeItem={activeItem} items={items} key={title}/>
            : <NavItem to={path} isActive={activeSection === id} key={title}>{title}</NavItem>
        })}
      </NavList>
    </Nav>
  </div>
)

const NavSection = ({title, isSectionActive, activeItem, items}) => {
  return (
    <NavExpandable title={title} isActive={isSectionActive} isExpanded={isSectionActive}>
      {items.map(({id, title, path}) => (
        path
          ? <NavItem to={path} isActive={isSectionActive && activeItem === id} key={title} >{title}</NavItem>
          : <NavGroup title={title} className='vertical-nav-label' key={title}></NavGroup>
      ))}
    </NavExpandable>
  )
}

const VerticalNavWrapper = (props: Props, containerId: string) => createReactWrapper(<VerticalNav {...props} />, containerId)

export { VerticalNav, VerticalNavWrapper }
