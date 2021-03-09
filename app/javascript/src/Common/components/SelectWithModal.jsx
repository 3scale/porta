// @flow

import * as React from 'react'

import {
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import {
  toSelectOption,
  toSelectOptionObject,
  SelectOptionObject
} from 'utilities/patternfly-utils'
import { TableModal } from 'Common'

import type { Record } from 'utilities/patternfly-utils'

type Props<T: Record> = {
  item: T | null,
  items: T[],
  onSelect: (T | null) => void,
  isDisabled?: boolean,
  label: string,
  id: string,
  name?: string,
  helperText?: React.Node,
  placeholderText?: string,
  maxItems?: number,
  header?: string,
  footer?: string,
  cells: { title: string, propName: string }[],
  modalTitle: string,
}

const MAX_ITEMS = 20
const HEADER = 'Most recently created'
const FOOTER = 'View all'

const SelectWithModal = <T: Record>({
  item,
  items,
  onSelect,
  isDisabled,
  label,
  id,
  name,
  helperText,
  placeholderText,
  maxItems = MAX_ITEMS,
  header = HEADER,
  footer = FOOTER,
  cells,
  modalTitle
}: Props<T>): React.Node => {
  const headerItem = { id: 'header', name: header, disabled: true, className: 'pf-c-select__menu-item--group-name' }
  const footerItem = { id: 'foo', name: footer }

  const [expanded, setExpanded] = React.useState(false)
  const [modalOpen, setModalOpen] = React.useState(false)

  const handleOnSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    if (option.id === footerItem.id) {
      setModalOpen(true)
    } else {
      const selectedBackend = items.find(b => String(b.id) === option.id)

      if (selectedBackend) {
        onSelect(selectedBackend)
      }
    }
  }

  const getItems = items => [
    headerItem,
    ...items.slice(0, maxItems).map(i => ({ ...i, className: 'pf-c-select__menu-item-description' })),
    footerItem
  ]

  const options = getItems(items).map(toSelectOption)

  const handleOnFilter = (e) => {
    const { value } = e.target
    const term = new RegExp(value, 'i')

    const filteredRecords: T[] = value !== '' ? items.filter(b => term.test(b.name)) : items
    const filteredItems = filteredRecords.length === 0
      ? [{ id: -1, name: 'No results found', disabled: true, privateEndpoint: '' }, footerItem]
      : getItems(filteredRecords)

    return filteredItems.map(toSelectOption)
  }

  return (
    <>
      <FormGroup
        isRequired
        label={label}
        fieldId={id}
        helperText={helperText}
      >
        {item && <input type="hidden" name={name} value={item.id} />}
        <Select
          variant={SelectVariant.typeahead}
          placeholderText="Select a item"
          selections={item && toSelectOptionObject(item)}
          onToggle={() => setExpanded(!expanded)}
          onSelect={handleOnSelect}
          isExpanded={expanded}
          isDisabled={isDisabled}
          onClear={() => onSelect(null)}
          aria-labelledby={id}
          className="pf-c-select__menu--with-fixed-link"
          isGrouped
          onFilter={handleOnFilter}
        >
          {options}
        </Select>
      </FormGroup>

      <TableModal
        title={modalTitle}
        cells={cells}
        isOpen={modalOpen}
        item={item}
        items={items}
        onSelect={b => {
          onSelect(b)
          setModalOpen(false)
        }}
        onClose={() => setModalOpen(false)}
      />
    </>
  )
}

export { SelectWithModal }
