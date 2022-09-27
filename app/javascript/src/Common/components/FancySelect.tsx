import * as React from 'react'

import {
  FormGroup,
  Select,
  SelectOptionObject as PFSelectOptionObject,
  SelectVariant
} from '@patternfly/react-core'
import {
  handleOnFilter,
  SelectOptionObject,
  toSelectOption,
  toSelectOptionObject
} from 'utilities'

import type { Record } from 'utilities'

import './FancySelect.scss'

type Item = Record & {
  disabled?: boolean,
  className?: string
}

type Props<T extends Record> = {
  item: T | undefined,
  items: T[],
  onSelect: (arg1: T | null) => void,
  label: string,
  id: string,
  header: string,
  isDisabled?: boolean,
  name?: string,
  helperText?: React.ReactNode,
  helperTextInvalid?: string,
  placeholderText?: string,
  footer?: {
    label: string,
    onClick: () => void
  }
};

const emptyItem = { id: -1, name: 'No results found', disabled: true, privateEndpoint: '' } as const
const FOOTER_ID = 'footer_id'

const FancySelect = <T extends Record>({
  item,
  items,
  onSelect,
  label,
  id,
  header,
  isDisabled,
  name,
  helperText,
  helperTextInvalid,
  placeholderText,
  footer
}: Props<T>) => {
  const [expanded, setExpanded] = React.useState(false)

  const headerItem = { id: 'header', name: header, disabled: true, className: 'pf-c-select__menu-item--group-name' } as const
  // TODO: Remove after upgrading @patternfly/react-core, see https://www.patternfly.org/v4/components/select#view-more
  const footerItem = footer && { id: FOOTER_ID, name: footer.label, className: 'pf-c-select__menu-item--sticky-footer' }

  const handleOnSelect = (_e: any, _option: string | PFSelectOptionObject) => {
    setExpanded(false)

    const option = (_option as SelectOptionObject)

    if (option.id === FOOTER_ID) {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      footer!.onClick()
    } else {
      const selectedBackend = items.find(b => String(b.id) === option.id)

      if (selectedBackend) {
        onSelect(selectedBackend)
      }
    }
  }

  const getSelectOptionsForItems = (items: Array<T>) => {
    const selectItems: Array<Item> = [headerItem]

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
      isValid={!helperTextInvalid}
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
        onFilter={handleOnFilter<T>(items, getSelectOptionsForItems)}
        placeholderText={placeholderText}
      >
        {getSelectOptionsForItems(items)}
      </Select>
    </FormGroup>
  )
}

export { FancySelect, Props }
