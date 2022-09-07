import * as React from 'react';
import { useState } from 'react'
import { FormGroup, TextInput } from '@patternfly/react-core'
import type { FieldGroupProps } from 'Settings/types'

const TextInputGroup = (
  {
    defaultValue,
    placeholder,
    label,
    name,
    hint,
    value,
    isDefaultValue = false,
    readOnly = false,
    inputType = 'text',
  }: FieldGroupProps,
): React.ReactElement => {
  const [ inputValue, setInputValue ] = useState(value)
  const onChange = (value: any, _e: any) => setInputValue(value)
  return (
    <FormGroup label={label} fieldId={`service_proxy_attributes_${name}_input`} helperText={hint}>
      <TextInput
        id={`service_proxy_attributes_${name}_input`}
        name={`service[proxy_attributes][${name}]`}
        placeholder={placeholder}
        value={isDefaultValue ? defaultValue : inputValue}
        type={inputType}
        onChange={onChange}
        isReadOnly={readOnly}
      />
    </FormGroup>
  )
}

export {
  TextInputGroup
}
