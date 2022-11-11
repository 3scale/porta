import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  systemName: string;
  setSystemName: (systemName: string) => void;
}

const SystemNameInput: FunctionComponent<Props> = ({ systemName, setSystemName }) => (
  <FormGroup
    fieldId="backend_api_system_name"
    helperText="Only ASCII letters, numbers, dashes, and underscores are allowed."
    label="SystemName"
    validated="default"
  >
    <TextInput
      id="backend_api_system_name"
      name="backend_api[system_name]"
      type="text"
      value={systemName}
      onChange={setSystemName}
    />
  </FormGroup>
)

export { SystemNameInput, Props }
