import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  privateEndpoint: string;
  setPrivateEndpoint: (privateEndpoint: string) => void;
  errors?: string[];
}

const PrivateEndpointInput: FunctionComponent<Props> = ({
  privateEndpoint,
  setPrivateEndpoint,
  errors = []
}) => (
  <FormGroup
    isRequired
    fieldId="backend_api_private_endpoint"
    helperText="The private address of your API that will be called by the API gateway. For end-to-end encryption, your private base URL scheme must use a secure protocol - https or wss."
    helperTextInvalid={errors[0]}
    isValid={errors.length === 0}
    label="Private Base URL"
    validated="default"
  >
    <TextInput
      id="backend_api_private_endpoint"
      isValid={errors.length === 0}
      name="backend_api[private_endpoint]"
      type="text"
      value={privateEndpoint}
      onChange={setPrivateEndpoint}
    />
  </FormGroup>
)

export type { Props }
export { PrivateEndpointInput }
