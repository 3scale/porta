import * as React from 'react'
import { useState } from 'react'

import { FormGroup, Select, SelectOption, SelectOptionObject } from '@patternfly/react-core'
import { FieldGroupProps, FieldCatalogProps } from 'Settings/types'

type Props = FieldGroupProps & FieldCatalogProps;

const SelectGroup: React.FunctionComponent<Props> = ({
  label,
  name,
  hint,
  value,
  catalog
}) => {
  const [ selectedValue, setSelectedValue ] = useState(value)
  const [ isExpanded, setIsExpanded ] = useState(false)
  const onSelect = (_e: any, selection: string | SelectOptionObject) => {
    setIsExpanded(false)
    setSelectedValue((selection as SelectOptionObject & { key: string }).key)
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
          <SelectOption key={catalog[key]} value={{ toString: () => catalog[key] }} />
        ))}
      </Select>
    </FormGroup>
  )
}

export { SelectGroup, Props }
