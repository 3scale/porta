import { useCallback, useEffect, useRef, useState } from 'react'
import {
  DataListAction,
  DataListCell,
  DataListItem,
  DataListItemCells,
  DataListItemRow,
  Dropdown,
  DropdownItem,
  DropdownPosition,
  KebabToggle
} from '@patternfly/react-core'

import { useClickOutside } from 'utilities/useClickOutside'

import type { FunctionComponent } from 'react'

interface Props {
  api: {
    id: number;
    link: string;
    links: {
      name: string;
      path: string;
    }[];
    name: string;
    type: string;
    // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
    updated_at: string;
  };
}

const APIDataListItem: FunctionComponent<Props> = ({ api: { id, name, updated_at: updatedAt, link, links } }) => {
  const [isOpen, setIsOpen] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  const handleClickOutside = useCallback((event: Event) => {
    if (ref.current && !ref.current.contains(event.target as HTMLDivElement)) {
      setIsOpen(false)
    }
  }, [ref])

  useClickOutside(ref, () => { setIsOpen(false) })

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
          aria-label="Actions"
          aria-labelledby="multi-actions-item1 multi-actions-action1"
          id="actions-menu"
        >
          <div ref={ref}>
            <Dropdown
              isPlain
              className="dashboard-list-item-action"
              dropdownItems={links.map(({ name: n, path }) => (
                <DropdownItem key={n} href={path}>{n}</DropdownItem>
              ))}
              id="actions-menu"
              isOpen={isOpen}
              position={DropdownPosition.right}
              toggle={<KebabToggle id={String(id)} />}
              onClick={() => { setIsOpen(!isOpen) }}
            />
          </div>
        </DataListAction>
      </DataListItemRow>
    </DataListItem>
  )
}

export type { Props }
export { APIDataListItem }
