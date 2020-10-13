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
import { useClickOutside } from 'utilities/useClickOutside'

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

const APIDataListItem = ({ api }: Props) => {
  const { id, name, updated_at: updatedAt, link } = api
  const [isOpen, setIsOpen] = useState(false)
  const ref = useRef(null)
  useClickOutside(ref, () => setIsOpen(false))

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
        </DataListAction>
      </DataListItemRow>
    </DataListItem>
  )
}

export { APIDataListItem }
