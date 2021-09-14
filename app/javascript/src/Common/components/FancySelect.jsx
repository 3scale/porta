// @flow

import * as React from 'react'

import {
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import {
  handleOnFilter,
  toSelectOption,
  toSelectOptionObject,
  SelectOptionObject
} from 'utilities'

import type { Record } from 'utilities'

import './FancySelect.scss'

type Props<T: Record> = {
  item: T | null,
  items: T[],
  onSelect: (T | null) => void,
  label: string,
  id: string,
  header: string,
  isDisabled?: boolean,
  isValid?: boolean,
  name?: string,
  helperText?: React.Node,
  helperTextInvalid?: string,
  placeholderText?: string,
  footer?: {
    label: string,
    onClick: () => void
  }
}

const emptyItem = { id: -1, name: 'No results found', disabled: true, privateEndpoint: '' }
const FOOTER_ID = 'footer_id'

const FancySelect = <T: Record>({
  item,
  items,
  onSelect,
  label,
  id,
  header,
  isDisabled,
  isValid,
  name,
  helperText,
  helperTextInvalid,
  placeholderText,
  footer
}: Props<T>): React.Node => {
  const [expanded, setExpanded] = React.useState(false)

  const headerItem = { id: 'header', name: header, disabled: true, className: 'pf-c-select__menu-item--group-name' }
  // TODO: Remove after upgrading @patternfly/react-core, see https://www.patternfly.org/v4/components/select#view-more
  const footerItem = footer && { id: FOOTER_ID, name: footer.label, className: 'pf-c-select__menu-item--sticky-footer' }

  const handleOnSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    if (option.id === FOOTER_ID) {
      // $FlowIgnore[incompatible-use] safe to assume onClick is defined at this point
      footer.onClick()
    } else {
      const selectedBackend = items.find(b => String(b.id) === option.id)

      if (selectedBackend) {
        onSelect(selectedBackend)
      }
    }
  }

  const getSelectOptionsForItems = (items: Array<T>) => {
    const selectItems = [headerItem]

    if (items.length === 0) {
      selectItems.push(emptyItem)
    } else {
      selectItems.push(...items.map(i => ({ ...i, className: 'pf-c-select__menu-item-description' })))
    }

    if (footerItem) {
      selectItems.push(footerItem)
    }

    return selectItems.map(toSelectOption)
  }

  return (
    <FormGroup
      isRequired
      label={label}
      fieldId={id}
      helperText={helperText}
      helperTextInvalid={helperTextInvalid}
      isValid={isValid}
    >
      {name && item && <input type="hidden" name={name} value={item.id} />}
      <Select
        variant={SelectVariant.typeahead}
        selections={item && toSelectOptionObject(item)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleOnSelect}
        isExpanded={expanded}
        isDisabled={isDisabled}
        onClear={() => onSelect(null)}
        aria-labelledby={id}
        className={footer ? 'pf-c-select__menu--with-fixed-link' : undefined}
        isGrouped
        // $FlowIgnore[incompatible-call] yes it is
        onFilter={handleOnFilter(items, getSelectOptionsForItems)}
        placeholderText={placeholderText}
      >
        {getSelectOptionsForItems(items)}
      </Select>
    </FormGroup>
  )
}

export { FancySelect }
