import React, { useState, useRef, useEffect, useCallback } from 'react'

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
    // eslint-disable-next-line camelcase
    updated_at: string
  }
}

const APIDataListItem = ({ api }: Props) => {
  const { id, name, updated_at: updatedAt, link, links } = api
  const [isOpen, setIsOpen] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  const handleClickOutside = useCallback((event: Event) => {
    if (ref.current && !ref.current.contains(event.target as HTMLDivElement)) {
      setIsOpen(false)
    }
  }, [ref])

  useClickOutside(ref, () => setIsOpen(false))

  useEffect(() => {
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside, false)
    } else {
      document.removeEventListener('mousedown', handleClickOutside, false)
    }
  }, [isOpen])

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
        >
          <div ref={ref}>
            <Dropdown
              isPlain
              id="actions-menu"
              position={DropdownPosition.right}
              isOpen={isOpen}
              className="dashboard-list-item-action"
              onClick={() => setIsOpen(!isOpen)}
              toggle={<KebabToggle id={id.toString()} />}
              dropdownItems={links.map(({ name, path }) => (
                <DropdownItem key={name} href={path}>{name}</DropdownItem>
              ))}
            />
          </div>
        </DataListAction>
      </DataListItemRow>
    </DataListItem>
  )
}

export { APIDataListItem, Props }
