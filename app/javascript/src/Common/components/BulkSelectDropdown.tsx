import { useEffect, useState } from 'react'
import {
  Dropdown,
  DropdownItem,
  DropdownPosition,
  DropdownToggle,
  DropdownToggleCheckbox
} from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  numSelected: number;
  pageEntries: number;
  setAllEntriesSelected: (set: boolean) => void;
  setSelectedItems: React.Dispatch<React.SetStateAction<string[]>>;
  totalEntries: number;
}

const BulkSelectDropdown: FunctionComponent<Props> = ({
  numSelected,
  pageEntries,
  setAllEntriesSelected,
  setSelectedItems,
  totalEntries
}) => {
  const [bulkSelectDropdownOpen, setBulkSelectDropdownOpen] = useState(false)

  const allSelected = numSelected === totalEntries
  const anySelected = numSelected > 0
  const isChecked = allSelected ? true : anySelected ? null : false

  useEffect(() => {
    document.querySelectorAll<HTMLInputElement>('table tbody .pf-c-table__check input')
      .forEach(checkbox => {
        checkbox.addEventListener('click', () => {
          const { checked, value } = checkbox

          setAllEntriesSelected(false)
          setSelectedItems(prev => checked ? [...prev, value] : prev.filter(i => i !== value))
        })
      })
  }, [])

  const items = [
    <DropdownItem key="item-1" onClick={handleSelectNone}>
      Select none (0 items)
    </DropdownItem>,
    <DropdownItem key="item-2" onClick={handleSelectPage}>
      Select page ({pageEntries} items)
    </DropdownItem>,
    <DropdownItem key="item-3" onClick={handleSelectAll}>
      Select all ({totalEntries} items)
    </DropdownItem>
  ]

  function handleSelectNone () {
    document.querySelectorAll<HTMLInputElement>('table tbody .pf-c-table__check input:checked')
      .forEach(checkbox => {
        checkbox.checked = false
      })

    setSelectedItems([])
    setAllEntriesSelected(false)
  }

  function handleSelectPage () {
    const newValues: string[] = []
    document.querySelectorAll<HTMLInputElement>('table tbody .pf-c-table__check input:not(:checked)')
      .forEach(checkbox => {
        checkbox.checked = true
        newValues.push(checkbox.value)
      })

    setSelectedItems(prev => [...prev, ...newValues])
    setAllEntriesSelected(false)
  }

  function handleSelectAll () {
    handleSelectPage()
    setAllEntriesSelected(true)
  }

  return (
    <Dropdown
      dropdownItems={items}
      isOpen={bulkSelectDropdownOpen}
      position={DropdownPosition.left}
      toggle={(
        <DropdownToggle
          splitButtonItems={[
            <DropdownToggleCheckbox
              key="bulk-select"
              aria-label={anySelected ? 'Deselect all' : 'Select all'}
              id="bulk-select"
              isChecked={isChecked}
              onClick={anySelected ? handleSelectNone : handleSelectAll}
            >
              {anySelected && `${numSelected} selected`}
            </DropdownToggleCheckbox>
          ]}
          onToggle={setBulkSelectDropdownOpen}
        />)}
      onSelect={() => { setBulkSelectDropdownOpen(false) }}
    />
  )
}

export type { Props }
export { BulkSelectDropdown }
