
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  email: string,
  setEmail: (arg1: string) => void,
  isRequired?: boolean,
  errors: string[]
}

const EmailInput = (
  {
    email,
    setEmail,
    isRequired,
    errors
  }: Props
): React.ReactElement => (
  <FormGroup
    fieldId="email_configuration_email"
    helperTextInvalid={errors.toString()}
    isRequired={isRequired}
    isValid={!errors.length}
    label="Email"
    validated="default"
  >
    <TextInput
      id="email_configuration_email"
      isValid={!errors.length}
      name="email_configuration[email]"
      type="text"
      value={email}
      onChange={setEmail}
    />
  </FormGroup>
)

export { EmailInput, Props }
