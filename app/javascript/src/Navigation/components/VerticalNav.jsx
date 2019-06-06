// @flow

import React from 'react'
import { Nav, NavExpandable, NavItem, NavList, NavGroup } from '@patternfly/react-core'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Item = {
  id: string,
  title: string,
  path: string
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
  <div className="pf-c-page__sidebar">
    <div className="pf-c-page__sidebar-body">
      <Nav>
        <NavList>
          {sections.map(({ id, title, path, items }) => items
            ? (
              <NavExpandable title={title} isActive={activeSection === id} isExpanded={activeSection === id}>
                {items.map(({id, title, path}) => (
                  <NavGroup key={title} title="">
                    <NavItem to={path} isActive={activeItem === id}>{title}</NavItem>
                  </NavGroup>
                ))}
              </NavExpandable>
            ) : (
              <NavItem to={path} isActive={activeSection === id}>
                {title}
              </NavItem>
            )
          )}
        </NavList>
      </Nav>
    </div>
  </div>
)

const VerticalNavWrapper = (props: Props, containerId: string) => createReactWrapper(<VerticalNav {...props} />, containerId)

export { VerticalNav, VerticalNavWrapper }
