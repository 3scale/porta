import { useState } from 'react'
import {
  FormGroup,
  Select as PF4Select,
  SelectVariant
} from '@patternfly/react-core'
import { Spinner } from 'Common'
import {
  handleOnFilter,
  toSelectOption,
  toSelectOptionObject
} from 'utilities'

import type {
  Record,
  SelectOptionObject } from 'utilities'
import type {
  SelectOptionObject as PFSelectOptionObject } from '@patternfly/react-core'

import './Select.scss'

type Props<T extends Record> = {
  item: T | null,
  items: T[],
  onSelect: (arg1: T | null) => void,
  label: React.ReactNode,
  ariaLabel?: string,
  fieldId: string,
  name: string,
  isClearable?: boolean,
  placeholderText?: string,
  hint?: React.ReactNode,
  isValid?: boolean,
  helperText?: string,
  helperTextInvalid?: string,
  isDisabled?: boolean,
  isLoading?: boolean,
  isRequired?: boolean
}

const Select = <T extends Record>(
  {
    item,
    items,
    onSelect,
    label,
    ariaLabel,
    fieldId,
    name,
    isClearable = true,
    placeholderText = '',
    hint,
    isValid = true,
    helperText,
    helperTextInvalid,
    isDisabled = false,
    isLoading = false,
    isRequired = false
  }: Props<T>
): React.ReactElement => {
  const [expanded, setExpanded] = useState(false)

  const handleSelect = (_e: any, option: string | PFSelectOptionObject) => {
    setExpanded(false)

    const selected = items.find(i => i.id.toString() === (option as SelectOptionObject).id)
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
      fieldId={fieldId}
      helperText={helperText}
      helperTextInvalid={helperTextInvalid}
      isRequired={isRequired}
      isValid={isValid}
      label={label}
    >
      {isLoading ? <Spinner className="pf-u-ml-md" size="md" /> : null}
      {item ? <input name={name} type="hidden" value={item.id > -1 ? item.id : ''} /> : null}
      <PF4Select
        aria-label={ariaLabel}
        className={isClearable ? '' : 'pf-m-select__toggle-clear-hidden'}
        id={fieldId}
        isDisabled={isDisabled}
        isExpanded={expanded}
        placeholderText={placeholderText}
        selections={(item && toSelectOptionObject(item)) || undefined}
        variant={SelectVariant.typeahead}
        onClear={handleOnClear}
        onFilter={handleOnFilter(items)}
        onSelect={handleSelect}
        onToggle={() => setExpanded(!expanded)}
      >
        {items.map(toSelectOption)}
      </PF4Select>
      {hint}
    </FormGroup>
  )
}

export { Select, Props }
