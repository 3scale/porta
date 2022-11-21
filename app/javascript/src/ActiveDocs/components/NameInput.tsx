import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  name: string;
  setName: (name: string) => void;
}

const NameInput: FunctionComponent<Props> = ({ name, setName }) => (
  <FormGroup
    isRequired
    fieldId="api_docs_service_name"
    label="Name"
    validated="default"
  >
    <TextInput
      id="api_docs_service_name"
      name="api_docs_service[name]"
      type="text"
      value={name}
      onChange={(value) => { setName(value) }}
    />
  </FormGroup>
)

export { NameInput, Props }
