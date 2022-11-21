import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  service: string;
  setService: (service: string) => void;
}

const ServiceInput: FunctionComponent<Props> = ({ service, setService }) => (
  <FormGroup
    isRequired
    fieldId="api_docs_service_service_id"
    label="Service"
    validated="default"
  >
    <TextInput
      id="api_docs_service_service_id"
      name="api_docs_service[service_id]"
      type="text"
      value={service}
      onChange={(value) => { setService(value) }}
    />
  </FormGroup>
)

export { ServiceInput, Props }
