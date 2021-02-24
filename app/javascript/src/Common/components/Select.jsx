// @flow

import * as React from 'react'

import { FormGroup, Select as PF4Select, SelectVariant } from '@patternfly/react-core'
import { toSelectOption, toSelectOptionObject, SelectOptionObject } from 'utilities/patternfly-utils'

import type { Record } from 'utilities/patternfly-utils'

type Props<T: Record> = {
  item: T | null,
  items: T[],
  onSelect: (T | null) => void,
  label: string,
  fieldId: string,
  name: string,
  placeholderText: string,
  hint?: React.Node,
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
  placeholderText,
  hint,
  isDisabled = false,
  isRequired = false
}: Props<T>) => {
  const [expanded, setExpanded] = React.useState(false)

  const handleSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    const selected = items.find(i => i.id.toString() === option.id)
    onSelect(selected || null)
  }

  return (
    <FormGroup
      isRequired={isRequired}
      label={label}
      fieldId={fieldId}
    >
      {item && <input type="hidden" name={name} value={item.id} />}
      <PF4Select
        id={fieldId}
        variant={SelectVariant.typeahead}
        placeholderText={placeholderText}
        // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
        selections={item && toSelectOptionObject(item)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby={fieldId}
        isDisabled={isDisabled}
      >
        {/* $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string" */}
        {items.map(toSelectOption)}
      </PF4Select>
      {hint}
    </FormGroup>
  )
}

export { Select }
