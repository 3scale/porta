
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  privateEndpoint: string,
  setPrivateEndpoint: (arg1: string) => void,
  errors?: Array<string>
};

const PrivateEndpointInput = (
  {
    privateEndpoint,
    setPrivateEndpoint,
    errors = []
  }: Props
): React.ReactElement => <FormGroup
  isRequired
  label="Private Base URL"
  validated="default"
  fieldId="backend_api_private_endpoint"
  helperText="The private address of your API that will be called by the API gateway. For end-to-end encryption, your private base URL scheme must use a secure protocol - https or wss."
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

export { PrivateEndpointInput, Props }
