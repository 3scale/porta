import { useState } from 'react'
import { FormGroup, Select, SelectOption } from '@patternfly/react-core'

import type { SelectOptionObject } from '@patternfly/react-core'
import type { FieldCatalogProps, FieldGroupProps } from 'Settings/types'

type Props = FieldGroupProps & FieldCatalogProps

const SelectGroup: React.FunctionComponent<Props> = ({
  label,
  name,
  hint,
  value,
  catalog
}) => {
  const [selectedValue, setSelectedValue] = useState(value)
  const [isExpanded, setIsExpanded] = useState(false)
  const onSelect = (_e: any, selection: string | SelectOptionObject) => {
    setIsExpanded(false)
    setSelectedValue((selection as SelectOptionObject & { key: string }).key)
  }

  return (
    <FormGroup fieldId={`service_proxy_attributes_${name}_select`} helperText={hint} label={label}>
      <input name={`service[proxy_attributes][${name}]`} type="hidden" value={selectedValue} />
      <Select
        id={`service_proxy_attributes_${name}_select`}
        isExpanded={isExpanded}
        selections={catalog[selectedValue]}
        onSelect={onSelect}
        onToggle={setIsExpanded}
      >
        {Object.keys(catalog).map(key => (
          <SelectOption key={catalog[key]} value={{ toString: () => catalog[key] }} />
        ))}
      </Select>
    </FormGroup>
  )
}

export { SelectGroup, Props }
