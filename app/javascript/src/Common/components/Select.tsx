import { useState } from 'react'
import {
  FormGroup,
  Select as PF4Select,
  SelectVariant
} from '@patternfly/react-core'

import { Spinner } from 'Common/components/Spinner'
import { handleOnFilter, toSelectOption, toSelectOptionObject } from 'utilities/patternfly-utils'
import type { IRecord, SelectOptionObject } from 'utilities/patternfly-utils'

import type {
  SelectOptionObject as PFSelectOptionObject,
  SelectProps
} from '@patternfly/react-core'

import './Select.scss'

interface Props<T extends IRecord> extends Pick<SelectProps, 'aria-label' | 'isDisabled' | 'placeholderText' | 'validated'> {
  item: T | null;
  items: T[];
  onSelect: (selected: T | null) => void;
  label: React.ReactNode;
  fieldId: string;
  name: string;
  isClearable?: boolean;
  hint?: React.ReactNode;
  helperText?: string;
  helperTextInvalid?: string;
  isLoading?: boolean;
  isRequired?: boolean;
}

const Select = <T extends IRecord>({
  item,
  items,
  onSelect,
  label,
  fieldId,
  name,
  isClearable = true,
  placeholderText = '',
  hint,
  validated,
  helperText,
  helperTextInvalid,
  isDisabled,
  isLoading = false,
  isRequired = false,
  ...rest
}: Props<T>): React.ReactElement => {
  const [expanded, setExpanded] = useState(false)

  const handleSelect = (_e: unknown, option: PFSelectOptionObject | string) => {
    setExpanded(false)

    const selected = items.find(i => i.id.toString() === (option as SelectOptionObject).id)
    onSelect(selected ?? null)
  }

  const handleOnClear = () => {
    if (isClearable) {
      onSelect(null)
      setExpanded(false)
    }
  }

  return (
    <FormGroup
      fieldId={fieldId}
      helperText={helperText}
      helperTextInvalid={helperTextInvalid}
      isRequired={isRequired}
      label={label}
      validated={validated}
    >
      {isLoading && <Spinner className="pf-u-ml-md" size="md" />}
      {/* Controllers expect an empty string for some operations (such as unsetting the default plan) */}
      {item && <input name={name} type="hidden" value={Number(item.id) >= 0 ? item.id : ''} />}
      <PF4Select
        aria-label={rest['aria-label']}
        className={isClearable ? '' : 'pf-m-select__toggle-clear-hidden'}
        id={fieldId}
        isDisabled={isDisabled}
        isOpen={expanded}
        placeholderText={placeholderText}
        selections={item ? toSelectOptionObject(item) : undefined}
        variant={SelectVariant.typeahead}
        onClear={handleOnClear}
        onFilter={handleOnFilter(items)}
        onSelect={handleSelect}
        onToggle={() => { setExpanded(!expanded) }}
      >
        {items.map(toSelectOption)}
      </PF4Select>
      {hint}
    </FormGroup>
  )
}

export type { Props }
export { Select }
