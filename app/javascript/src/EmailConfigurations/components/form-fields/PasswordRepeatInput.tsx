
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  password: string,
  setPassword: (arg1: string) => void,
  errors: string[],
  isRequired?: boolean,
  isDisabled?: boolean
};

const PasswordRepeatInput = (
  {
    password,
    setPassword,
    errors,
    isRequired,
    isDisabled
  }: Props
): React.ReactElement => <FormGroup
  isRequired={isRequired}
  label="Confirm password"
  validated="default"
  fieldId="email_configuration_password_repeat"
  isValid={!errors.length}
  helperTextInvalid={errors.toString()}
>
  <TextInput
    type="password"
    id="email_configuration_password_repeat"
    value={password}
    onChange={setPassword}
    isValid={!errors.length}
    isDisabled={isDisabled}
    autoComplete="new-password"
  />
</FormGroup>

export { PasswordRepeatInput, Props }
