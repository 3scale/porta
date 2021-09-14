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
  SelectOptionObject,
  handleOnFilter
} from 'utilities'
import { TableModal } from 'Common'

import type { Record } from 'utilities'

import './SelectWithModal.scss'

type Props<T: Record> = {
  item: T | null,
  items: T[],
  onSelect: (T | null) => void,
  isDisabled?: boolean,
  isValid?: boolean,
  label: string,
  id: string,
  name?: string,
  helperText?: React.Node,
  helperTextInvalid?: string,
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
  isValid,
  label,
  id,
  name,
  helperText,
  helperTextInvalid,
  placeholderText,
  maxItems = MAX_ITEMS,
  header = HEADER,
  footer = FOOTER,
  cells,
  modalTitle
}: Props<T>): React.Node => {
  const emptyItem = { id: -1, name: 'No results found', disabled: true, privateEndpoint: '' }
  const headerItem = { id: 'header', name: header, disabled: true, className: 'pf-c-select__menu-item--group-name' }
  const footerItem = { id: 'foo', name: footer, className: 'pf-c-select__menu-item--view-all' }
  const shouldShowFooter = items.length > MAX_ITEMS

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

  // Takes an array of local items and returns the list of options for the select.
  // If the sum of all items is higher than 20, display link button to "View all Products"
  const getSelectOptions = (forItems: Array<T>) => {
    const selectItems = [headerItem]

    if (forItems.length === 0) {
      selectItems.push(emptyItem)
    } else {
      selectItems.push(...forItems.slice(0, maxItems).map(i => ({ ...i, className: 'pf-c-select__menu-item-description' })))
    }

    if (shouldShowFooter) {
      selectItems.push(footerItem)
    }

    return selectItems.map(toSelectOption)
  }

  const options = getSelectOptions(items)

  return (
    <>
      <FormGroup
        isRequired
        label={label}
        fieldId={id}
        helperText={helperText}
        helperTextInvalid={helperTextInvalid}
        isValid={isValid}
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
          className={shouldShowFooter ? 'pf-c-select__menu--with-fixed-link' : undefined}
          isGrouped
          // $FlowIssue[incompatible-call] should not complain about plan having id as number, since Record has union "number | string"
          onFilter={handleOnFilter(items)}
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
