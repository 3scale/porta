// @flow

import * as React from 'react'

import { FormGroup, Select as PF4Select, SelectVariant } from '@patternfly/react-core'
import { toSelectOption, toSelectOptionObject, SelectOptionObject } from 'utilities'

import type { Record } from 'utilities'

type Props<T: Record> = {
  item: T | null,
  items: T[],
  onSelect: (T | null) => void,
  label: React.Node,
  fieldId: string,
  name: string,
  placeholderText?: string,
  hint?: React.Node,
  isValid?: boolean,
  helperTextInvalid?: string,
  isDisabled?: boolean,
  isRequired?: boolean
}

const Select = <T: Record>({
  item,
  items,
  onSelect,
  label,
  fieldId,
  name,
  placeholderText = '',
  hint,
  isValid = true,
  helperTextInvalid,
  isDisabled = false,
  isRequired = false
}: Props<T>): React.Node => {
  const [expanded, setExpanded] = React.useState(false)

  const handleSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    const selected = items.find(i => i.id.toString() === option.id)
    onSelect(selected || null)
  }

  const handleFilter = (e: SyntheticInputEvent<HTMLInputElement>) => {
    const { value } = e.currentTarget
    let filteredItems = items

    if (value !== '') {
      const term = new RegExp(value, 'i')
      filteredItems = items.filter(i => term.test(i.name))
    }

    // $FlowIssue[prop-missing] className and disabled are optional
    return filteredItems.map(toSelectOption)
  }

  return (
    <FormGroup
      isRequired={isRequired}
      label={label}
      fieldId={fieldId}
      isValid={isValid}
      helperTextInvalid={helperTextInvalid}
    >
      {item && <input type="hidden" name={name} value={item.id} />}
      <PF4Select
        id={fieldId}
        variant={SelectVariant.typeahead}
        placeholderText={placeholderText}
        selections={item && toSelectOptionObject(item)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby={fieldId}
        isDisabled={isDisabled}
        onFilter={handleFilter}
      >
        {/* $FlowIssue[prop-missing] className and disabled are optional */}
        {items.map(toSelectOption)}
      </PF4Select>
      {hint}
    </FormGroup>
  )
}

export { Select }
