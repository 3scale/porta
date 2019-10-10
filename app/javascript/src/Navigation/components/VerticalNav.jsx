// @flow

import React from 'react'
import { Nav, NavExpandable, NavItem, NavList, NavGroup } from 'Navigation/components/PF4NavProxy'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Item = {
  id: string,
  title: string,
  path: ?string,
  target: ?string,
  outOfDateConfig: ?boolean
}

type Section = Item & {
  items: ?Item[],
  outOfDateConfig: ?boolean
}

type Props = {
  sections: Section[],
  activeSection: ?string,
  activeItem: ?string
}

const VerticalNav = ({ sections, activeSection, activeItem }: Props) => (
  <div className="pf-c-page__sidebar-body">
    <Nav id='mainmenu'>
      <NavList>
        {sections.map(({ id, title, path, items, outOfDateConfig }) => {
          return items
            ? <NavSection title={title} isSectionActive={id === activeSection} activeItem={activeItem} items={items} key={title} outOfDateConfig={outOfDateConfig}/>
            : <NavItem to={path} isActive={activeSection === id} key={title}>{title}</NavItem>
        })}
      </NavList>
    </Nav>
  </div>
)

const NavSection = ({title, isSectionActive, activeItem, items, outOfDateConfig}) => {
  return (
    <NavExpandable title={title} isActive={isSectionActive} isExpanded={isSectionActive} outOfDateConfig={outOfDateConfig}>
      {items.map(({id, title, path, target, outOfDateConfig}) => (
        path
          ? <NavItem to={path} isActive={isSectionActive && activeItem === id} target={target} key={title} outOfDateConfig={outOfDateConfig} >{title}</NavItem>
          : <NavGroup title={title} className='vertical-nav-label' key={title}></NavGroup>
      ))}
    </NavExpandable>
  )
}

const VerticalNavWrapper = (props: Props, containerId: string) => createReactWrapper(<VerticalNav {...props} />, containerId)

export { VerticalNav, VerticalNavWrapper }
