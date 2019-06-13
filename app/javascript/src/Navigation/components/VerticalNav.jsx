// @flow

import React from 'react'
import { Nav, NavExpandable, NavItem, NavList, NavGroup } from 'Navigation/components/PF4NavProxy'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Item = {
  id: string,
  title: string,
  path: string,
  target: ?string
}

type Section = {
  id: string,
  title: string,
  path: string,
  items: Item[]
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
        {sections.map(({ id, title, path, items }) => {
          const sId = id
          return items
            ? (
              <NavExpandable title={title} isActive={activeSection === sId} isExpanded={activeSection === sId}>
                {items.map(({id, title, path, target}) => (
                  path
                    ? <NavItem to={path} isActive={activeSection === sId && activeItem === id} target={target}>{title}</NavItem>
                    : <NavGroup title={title} className='vertical-nav-label'></NavGroup>
                ))}
              </NavExpandable>
            ) : (
              <NavItem to={path} isActive={activeSection === sId}>
                {title}
              </NavItem>
            )
        })}
      </NavList>
    </Nav>
  </div>
)

const VerticalNavWrapper = (props: Props, containerId: string) => createReactWrapper(<VerticalNav {...props} />, containerId)

export { VerticalNav, VerticalNavWrapper }
