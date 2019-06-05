// @flow

import React, { useState } from 'react'
import { Nav, NavExpandable, NavItem, NavList, NavGroup } from '@patternfly/react-core'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Item = {
  title: string,
  path: string
}

type Props = {
  itemGroups: { [string]: Item[]}
}

const VerticalNav = ({ itemGroups }: Props) => {
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
              id="simple-link1"
              preventDefault
              to="#simple-link1"
              itemId='overview'
              isActive={activeItem === 'overview'}
            >
              Overview
            </NavItem>

            {Object.keys(itemGroups).map(groupId => (
              <NavExpandable
                title={groupId}
                // srText={groupId}
                groupId={groupId}
                isActive={activeGroup === groupId}
                // isExpanded
              >
                {itemGroups[groupId].map(item => (
                  <NavGroup title="">
                    <NavItem
                      preventDefault
                      to={item.path}
                      groupId={groupId}
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
