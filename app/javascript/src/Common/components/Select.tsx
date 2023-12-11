import { useState } from 'react'
import {
  FormGroup,
  Select as PF4Select,
  SelectVariant,
  Spinner
} from '@patternfly/react-core'

import { handleOnFilter, toSelectOption, toSelectOptionObject } from 'utilities/patternfly-utils'
import type { IRecord, SelectOptionObject } from 'utilities/patternfly-utils'

import type {
  FormGroupProps,
  SelectOptionObject as PFSelectOptionObject,
  SelectProps
} from '@patternfly/react-core'

interface Props<T extends IRecord> extends
  Omit<SelectProps, 'label' | 'onSelect' | 'onToggle'>,
  Pick<FormGroupProps, 'helperText' | 'helperTextInvalid' | 'isRequired' | 'label'> {
  item: T | null;
  items: T[];
  onSelect: (selected: T | null) => void;
  fieldId: string;
  name: string;
  isClearable?: boolean;
  hint?: React.ReactNode;
  isLoading?: boolean;
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
    onSelect(null)
    setExpanded(false)
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
        id={fieldId}
        isDisabled={isDisabled}
        isOpen={expanded}
        ouiaId={rest.ouiaId ?? label as string}
        placeholderText={placeholderText}
        selections={item ? toSelectOptionObject(item) : undefined}
        variant={SelectVariant.typeahead}
        onClear={isClearable ? handleOnClear : undefined}
        onFilter={handleOnFilter(items)}
        onSelect={handleSelect}
        onToggle={() => { setExpanded(!expanded) }}
        // eslint-disable-next-line react/jsx-props-no-spreading
        {...rest}
      >
        {items.map(toSelectOption)}
      </PF4Select>
      {hint}
    </FormGroup>
  )
}

export type { Props }
export { Select }
