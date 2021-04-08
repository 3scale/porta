// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'
import { Select } from 'Common'

import type { FieldDefinition } from 'Types'

type Props = {
  fieldDefinition: FieldDefinition,
  value: string,
  onChange: string => void,
  validationErrors?: string[]
}

const UserDefinedField = ({ fieldDefinition, value, onChange, validationErrors = [] }: Props): React.Node => {
  const { id, label, required, name, choices } = fieldDefinition

  const item = value ? { id: value, name: value } : null

  const handleOnSelect = i => onChange(i !== null ? i.name : '')

  const isValid = validationErrors.length === 0
  // TODO: 'isValid' prop is deprecated, when PF4 is up-to-date replace it with:
  // const validated = validationErrors.length > 0 ? 'error' : 'default'

  return choices ? (
    <Select
      label={label}
      isRequired={required}
      fieldId={id}
      name={name}
      item={item}
      items={choices.map(str => ({
        id: str,
        name: str
      }))}
      isValid={isValid}
      helperTextInvalid={validationErrors[0]}
      onSelect={handleOnSelect}
    />
  ) : (
    <FormGroup
      label={label}
      isRequired={required}
      isValid={isValid}
      helperTextInvalid={validationErrors[0]}
      fieldId={id}
    >
      <TextInput
        isValid={isValid}
        type="text"
        id={id}
        name={name}
        value={value}
        onChange={onChange}
      />
    </FormGroup>
  )
}

export { UserDefinedField }
