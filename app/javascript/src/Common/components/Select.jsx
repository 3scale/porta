// @flow

import * as React from 'react'

import { FormGroup, Select as PF4Select, SelectVariant } from '@patternfly/react-core'
import {
  toSelectOption,
  toSelectOptionObject,
  SelectOptionObject,
  handleOnFilter
} from 'utilities'

import type { Record } from 'utilities'

import './Select.scss'

type Props<T: Record> = {
  item: T | null,
  items: T[],
  onSelect: (T | null) => void,
  label: React.Node,
  fieldId: string,
  name: string,
  isClearable?: boolean,
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
  isClearable = true,
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

  const handleOnClear = () => {
    if (isClearable) {
      onSelect(null)
      setExpanded(false) // TODO: in PF4 this is done automatically. Remove this after upgrading.
    }
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
        onClear={handleOnClear}
        aria-labelledby={fieldId}
        isDisabled={isDisabled}
        // $FlowIssue[incompatible-call] should not complain about plan having id as number, since Record has union "number | string"
        onFilter={handleOnFilter(items)}
        className={isClearable ? '' : 'pf-m-select__toggle-clear-hidden'}
      >
        {/* $FlowIssue[prop-missing] className and disabled are optional */}
        {items.map(toSelectOption)}
      </PF4Select>
      {hint}
    </FormGroup>
  )
}

export { Select }
