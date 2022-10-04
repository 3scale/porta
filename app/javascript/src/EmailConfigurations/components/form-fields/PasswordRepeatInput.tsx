
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  password: string,
  setPassword: (arg1: string) => void,
  errors: string[],
  isRequired?: boolean,
  isDisabled?: boolean
}

const PasswordRepeatInput = (
  {
    password,
    setPassword,
    errors,
    isRequired,
    isDisabled
  }: Props
): React.ReactElement => (
  <FormGroup
    fieldId="email_configuration_password_repeat"
    helperTextInvalid={errors.toString()}
    isRequired={isRequired}
    isValid={!errors.length}
    label="Confirm password"
    validated="default"
  >
    <TextInput
      autoComplete="new-password"
      id="email_configuration_password_repeat"
      isDisabled={isDisabled}
      isValid={!errors.length}
      type="password"
      value={password}
      onChange={setPassword}
    />
  </FormGroup>
)

export { PasswordRepeatInput, Props }
