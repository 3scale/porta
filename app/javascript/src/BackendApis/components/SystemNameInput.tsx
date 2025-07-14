import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  systemName: string;
  setSystemName: (systemName: string) => void;
  errors?: string[];
}

const emptyArray = [] as never[]

const SystemNameInput: FunctionComponent<Props> = ({
  systemName,
  setSystemName,
  errors = emptyArray
}) => {
  const validated = errors.length === 0 ? 'default' : 'error'
  return (
    <FormGroup
      fieldId="backend_api_system_name"
      helperText="Only ASCII letters, numbers, dashes, and underscores are allowed."
      helperTextInvalid={errors[0]}
      label="SystemName"
      validated={validated}
    >
      <TextInput
        id="backend_api_system_name"
        name="backend_api[system_name]"
        type="text"
        validated={validated}
        value={systemName}
        onChange={setSystemName}
      />
    </FormGroup>
  )
}

export type { Props }
export { SystemNameInput }
