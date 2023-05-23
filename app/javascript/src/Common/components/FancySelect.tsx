import { useState } from 'react'
import {
  Button,
  FormGroup,
  Select,
  SelectGroup,
  SelectVariant
} from '@patternfly/react-core'

import { toSelectOption, toSelectOptionObject, handleOnFilter } from 'utilities/patternfly-utils'
import type { IRecord, SelectOptionObject } from 'utilities/patternfly-utils'

import type { ReactElement } from 'react'
import type { SelectOptionObject as PFSelectOptionObject } from '@patternfly/react-core'

import './FancySelect.scss'

interface Props<T extends IRecord> {
  item: T | undefined;
  items: T[];
  onSelect: (selected: T | null) => void;
  label: string;
  id: string;
  header: string;
  isDisabled?: boolean;
  name?: string;
  helperText?: React.ReactNode;
  helperTextInvalid?: string;
  placeholderText?: string;
  footer?: {
    label: string;
    onClick: () => void;
  };
}

const FancySelect = <T extends IRecord>({
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
}: Props<T>): ReactElement => {
  const [expanded, setExpanded] = useState(false)

  const handleOnSelect = (_e: unknown, _option: PFSelectOptionObject | string) => {
    setExpanded(false)

    const option = (_option as SelectOptionObject)
    const selectedBackend = items.find(b => String(b.id) === option.id)

    if (selectedBackend) {
      onSelect(selectedBackend)
    }
  }

  const options = [
    <SelectGroup key={0} label={header}>
      {items.map(toSelectOption)}
    </SelectGroup>
  ]

  return (
    <FormGroup
      isRequired
      fieldId={id}
      helperText={helperText}
      helperTextInvalid={helperTextInvalid}
      label={label}
      validated={helperTextInvalid ? 'error' : 'default'}
    >
      {!!name && item && <input name={name} type="hidden" value={item.id} />}
      <Select
        isGrouped
        aria-labelledby={id}
        // eslint-disable-next-line react/jsx-props-no-spreading
        {...footer && {
          className: 'pf-c-select__menu--with-sticky-footer',
          footer: <Button isInline variant="link" onClick={footer.onClick}>{footer.label}</Button>
        }}
        isDisabled={isDisabled}
        isOpen={expanded}
        placeholderText={placeholderText}
        selections={item && toSelectOptionObject(item)}
        variant={SelectVariant.typeahead}
        onClear={() => { onSelect(null) }}
        onFilter={handleOnFilter(items)}
        onSelect={handleOnSelect}
        onToggle={() => { setExpanded(!expanded) }}
      >
        {options}
      </Select>
    </FormGroup>
  )
}

export type { Props }
export { FancySelect }
