import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  privateEndpoint: string;
  setPrivateEndpoint: (privateEndpoint: string) => void;
  errors?: string[];
}

const emptyArray = [] as never[]

const PrivateEndpointInput: FunctionComponent<Props> = ({
  privateEndpoint,
  setPrivateEndpoint,
  errors = emptyArray
}) => {
  const validated = errors.length === 0 ? 'default' : 'error'
  return (
    <FormGroup
      isRequired
      fieldId="backend_api_private_endpoint"
      helperText="The private address of your API that will be called by the API gateway. For end-to-end encryption, your private base URL scheme must use a secure protocol - https or wss."
      helperTextInvalid={errors[0]}
      label="Private Base URL"
      validated={validated}
    >
      <TextInput
        id="backend_api_private_endpoint"
        name="backend_api[private_endpoint]"
        type="text"
        validated={validated}
        value={privateEndpoint}
        onChange={setPrivateEndpoint}
      />
    </FormGroup>
  )
}

export type { Props }
export { PrivateEndpointInput }
