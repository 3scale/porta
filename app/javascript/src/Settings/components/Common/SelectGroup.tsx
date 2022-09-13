import * as React from 'react'
import { useState } from 'react'
import { FormGroup, Select, SelectOption } from '@patternfly/react-core'
import type { FieldGroupProps, FieldCatalogProps } from 'Settings/types'

type Props = FieldGroupProps & FieldCatalogProps;

const SelectGroup = (
  {
    label,
    name,
    hint,
    value,
    catalog
  }: Props
): React.ReactElement => {
  const [ selectedValue, setSelectedValue ] = useState(value)
  const [ isExpanded, setIsExpanded ] = useState(false)
  const onSelect = (_e: any, selection: any) => {
    setIsExpanded(false)
    setSelectedValue(selection.key)
  }

  return (
    <FormGroup label={label} fieldId={`service_proxy_attributes_${name}_select`} helperText={hint}>
      <input name={`service[proxy_attributes][${name}]`} type='hidden' value={selectedValue} />
      <Select
        selections={catalog[selectedValue]}
        onToggle={setIsExpanded}
        onSelect={onSelect}
        isExpanded={isExpanded}
        id={`service_proxy_attributes_${name}_select`}
      >
        {Object.keys(catalog).map(key => (
          <SelectOption key={catalog[key]} value={{ key, toString: () => catalog[key] }} />
        ))}
      </Select>
    </FormGroup>
  )
}

export {
  SelectGroup
}
