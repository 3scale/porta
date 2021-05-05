// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  privateEndpoint: string,
  setPrivateEndpoint: string => void,
  errors?: Array<string>
}

const PrivateEndpointInput = ({ privateEndpoint, setPrivateEndpoint, errors = [] }: Props): React.Node => (
  <FormGroup
    isRequired
    label="Private Base URL"
    validated="default"
    fieldId="backend_api_private_endpoint"
    helperText="Private address of your API that will be called by the API gateway. For end-to-end encryption your private base URL scheme should use a secure protocol (https or wss)."
    helperTextInvalid={errors ? errors[0] : ''}
    isValid={errors.length === 0}
  >
    <TextInput
      type="text"
      id="backend_api_private_endpoint"
      name="backend_api[private_endpoint]"
      value={privateEndpoint}
      onChange={setPrivateEndpoint}
      isValid={errors.length === 0}
    />
  </FormGroup>
)

export { PrivateEndpointInput }
