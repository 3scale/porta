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

const UserDefinedField: FunctionComponent<Props> = ({
  fieldDefinition,
  value,
  onChange,
  validationErrors = []
}) => {
  const { id, label, required, name, choices } = fieldDefinition

  const item = value ? { id: value, name: value } : null

  const handleOnSelect = (i: {
    description?: string;
    id: number | string;
    name: string;
  } | null) => { onChange(i !== null ? i.name : '') }

  const isValid = validationErrors.length === 0
  // TODO: 'isValid' prop is deprecated, when PF4 is up-to-date replace it with:
  // const validated = validationErrors.length > 0 ? 'error' : 'default'

  return choices ? (
    <Select
      fieldId={id}
      helperTextInvalid={validationErrors[0]}
      isRequired={required}
      isValid={isValid}
      item={item}
      items={choices.map(str => ({
        id: str,
        name: str
      }))}
      label={label}
      name={name}
      onSelect={handleOnSelect}
    />
  ) : (
    <FormGroup
      fieldId={id}
      helperTextInvalid={validationErrors[0]}
      isRequired={required}
      isValid={isValid}
      label={label}
    >
      <TextInput
        id={id}
        isValid={isValid}
        name={name}
        type="text"
        value={value}
        onChange={onChange}
      />
    </FormGroup>
  )
}

export type { Props }
export { UserDefinedField }
