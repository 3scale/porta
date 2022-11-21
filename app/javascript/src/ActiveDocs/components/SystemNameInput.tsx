import { FormGroup, TextInput, Alert } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  systemName: string;
  setSystemName: (systemName: string) => void;
}

const SystemNameInput: FunctionComponent<Props> = ({ systemName, setSystemName }) => (
  <FormGroup
    fieldId="api_docs_service_system_name"
    helperText="Only ASCII letters, numbers, dashes and underscores are allowed."
    label="SystemName"
    validated="default"
  >
    <TextInput
      id="api_docs_service_system_name"
      name="api_docs_service[system_name]"
      type="text"
      value={systemName}
      onChange={setSystemName}
    />
    <Alert title="Warning: With ActiveDocs 1.2 the API will be described in your developer portal as System name: Description" variant="warning" />
  </FormGroup>
)

export { SystemNameInput, Props }
