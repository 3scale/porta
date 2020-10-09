import React, { useState, useRef } from 'react'

import {
  Dropdown,
  DropdownItem,
  DropdownPosition,
  KebabToggle,
  DataListItem,
  DataListCell,
  DataListItemRow,
  DataListItemCells,
  DataListAction
} from '@patternfly/react-core'

type Props = {
  api: {
    id: number,
    link: string,
    links: Array<{
      name: string,
      path: string
    }>,
    name: string,
    type: string,
    updated_at: string
  }
}

const APIDataListItem = ({ api }: Props, isProduct) => {
  const { id, name, updated_at: updatedAt, link, links } = api
  const [isOpen, setIsOpen] = useState(false)
  const ref = useRef(null)
  // TODO: useClickOutside(ref, () => setIsOpen(false))

  console.log('what is type' + isProduct)

  return (
    <DataListItem key={id} aria-labelledby="single-action-item1">
      <DataListItemRow>
        <DataListItemCells
          dataListCells={[
            <DataListCell key="primary content">
              <a href={link} id="single-action-item1">
                {name}
              </a>
            </DataListCell>,
            <DataListCell key="secondary content" className="dashboard-list-secondary">
              {updatedAt}
            </DataListCell>
          ]}
        />
        <DataListAction
          aria-labelledby="multi-actions-item1 multi-actions-action1"
          id="actions-menu"
          aria-label="Actions"
          isPlainButtonAction
        >
          { isProduct ? (
            <Dropdown
              isPlain
              id="actions-menu"
              ref={ref}
              position={DropdownPosition.right}
              isOpen={isOpen}
              className="dashboard-list-item-action"
              onClick={() => setIsOpen(!isOpen)}
              toggle={<KebabToggle id={id.toString()} />}
              dropdownItems={api.links.map(({ name, path }) => (
                <DropdownItem key={name} href={path}>{name}</DropdownItem>
              ))}
            />
          ) : (
            <Dropdown
              isPlain
              id="actions-menu"
              ref={ref}
              position={DropdownPosition.right}
              isOpen={isOpen}
              className="dashboard-list-item-action"
              onClick={() => setIsOpen(!isOpen)}
              toggle={<KebabToggle id={id.toString()} />}
              dropdownItems={[
                <DropdownItem key={`link-${links[0].path}`} href={links[0].path}>
                  Edit
                </DropdownItem>,
                <DropdownItem key={`link-${links[1].path}`} href={links[1].path}>
                  Overview
                </DropdownItem>,
                <DropdownItem key={`link-${links[2].path}`} href={links[2].path}>
                  Analytics
                </DropdownItem>,
                <DropdownItem key={`link-${links[3].path}`} href={links[3].path}>
                  Methods and Metrics
                </DropdownItem>,
                <DropdownItem key={`link-${links[4].path}`} href={links[4].path}>
                  Mapping Rules
                </DropdownItem>
              ]}
            />
          )}
        </DataListAction>
      </DataListItemRow>
    </DataListItem>
  )
}

export { APIDataListItem }
