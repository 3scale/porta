// @flow

import React, { useState } from 'react'
import { Nav, NavExpandable, NavItem, NavList, NavGroup } from '@patternfly/react-core'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Item = {
  title: string,
  path: string
}

type Section = {
  title: string,
  items: Item[]
}

type Props = {
  sections: Section[]
}

const VerticalNav = ({ sections }: Props) => {
  const [activeItem, setActiveItem] = useState()
  const [activeGroup, setActiveGroup] = useState()

  function onSelect (res) {
    setActiveItem(res.itemId)
    setActiveGroup(res.groupId)
  }

  return (
    <div className="pf-c-page__sidebar">
      <div className="pf-c-page__sidebar-body">
        <Nav onSelect={onSelect}>
          <NavList>
            <NavItem
              to="#simple-link1"
              itemId='overview'
              isActive={activeItem === 'overview'}
            >
              Overview
            </NavItem>

            {sections.map(section => (
              <NavExpandable
                title={section.title}
                // srText={groupId}
                groupId={section.title}
                isActive={activeGroup === section.title}
                // isExpanded
              >
                {section.items.map(item => (
                  <NavGroup title="">
                    <NavItem
                      to={item.path}
                      groupId={section.title}
                      itemId={item.title}
                      isActive={activeItem === item.title}
                    >
                      {item.title}
                    </NavItem>
                  </NavGroup>
                ))}
              </NavExpandable>
            ))}
          </NavList>
        </Nav>
      </div>
    </div>
  )
}

const VerticalNavWrapper = (props: Props, containerId: string) => createReactWrapper(<VerticalNav {...props} />, containerId)

export { VerticalNav, VerticalNavWrapper }
