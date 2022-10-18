import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

type Props = {
  password: string,
  setPassword: (password: string) => void,
  errors: string[],
  isRequired?: boolean,
  isDisabled?: boolean
}

const PasswordRepeatInput: FunctionComponent<Props> = ({
  password,
  setPassword,
  errors,
  isRequired,
  isDisabled
}) => (
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
