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
  const [inputValue, setInputValue] = useState(value)
  const onChange = (value: string) => setInputValue(value)
  return (
    <FormGroup fieldId={`service_proxy_attributes_${name}_input`} helperText={hint} label={label}>
      <TextInput
        id={`service_proxy_attributes_${name}_input`}
        isReadOnly={readOnly}
        name={`service[proxy_attributes][${name}]`}
        placeholder={placeholder}
        type={inputType}
        value={isDefaultValue ? defaultValue : inputValue}
        onChange={onChange}
      />
    </FormGroup>
  )
}

export { TextInputGroup, FieldGroupProps as Props }
