import * as React from 'react'
import { useState } from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'
import { FieldGroupProps } from 'Settings/types'

const TextInputGroup: React.FunctionComponent<FieldGroupProps> = ({
  defaultValue,
  placeholder,
  label,
  name,
  hint,
  value,
  isDefaultValue = false,
  readOnly = false,
  inputType = 'text'
}) => {
  const [ inputValue, setInputValue ] = useState(value)
  const onChange = (value: string) => setInputValue(value)
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

export { TextInputGroup, FieldGroupProps as Props }
