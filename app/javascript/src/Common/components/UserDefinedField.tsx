import { FormGroup, TextInput } from '@patternfly/react-core'

import { Select } from 'Common/components/Select'

import type { FunctionComponent } from 'react'
import type { FieldDefinition } from 'Types'

interface Props {
  fieldDefinition: FieldDefinition;
  value: string;
  onChange: (value: string) => void;
  validationErrors?: string[];
}

const emptyArray = [] as never[]

const UserDefinedField: FunctionComponent<Props> = ({
  fieldDefinition,
  value,
  onChange,
  validationErrors = emptyArray
}) => {
  const { id, label, required, name, choices } = fieldDefinition

  const item = value ? { id: value, name: value } : null

  const handleOnSelect = (i: {
    description?: string;
    id: number | string;
    name: string;
  } | null) => { onChange(i !== null ? i.name : '') }

  const validated = validationErrors.length > 0 ? 'error' : 'default'

  return choices ? (
    <Select
      fieldId={id}
      helperTextInvalid={validationErrors[0]}
      isRequired={required}
      item={item}
      items={choices.map(str => ({
        id: str,
        name: str
      }))}
      label={label}
      name={name}
      validated={validated}
      onSelect={handleOnSelect}
    />
  ) : (
    <FormGroup
      fieldId={id}
      helperTextInvalid={validationErrors[0]}
      isRequired={required}
      label={label}
      validated={validated}
    >
      <TextInput
        id={id}
        name={name}
        type="text"
        validated={validated}
        value={value}
        onChange={onChange}
      />
    </FormGroup>
  )
}

export type { Props }
export { UserDefinedField }
