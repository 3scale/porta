import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

type Props = {
  password: string,
  setPassword: (password: string) => void,
  isRequired?: boolean,
  errors: string[]
}

const PasswordInput: FunctionComponent<Props> = ({
  password,
  setPassword,
  isRequired,
  errors
}) => (
  <FormGroup
    fieldId="email_configuration_password"
    helperTextInvalid={errors.toString()}
    isRequired={isRequired}
    isValid={!errors.length}
    label="Password"
    validated="default"
  >
    <TextInput
      autoComplete="new-password"
      id="email_configuration_password"
      isValid={!errors.length}
      name="email_configuration[password]"
      type="password"
      value={password}
      onChange={setPassword}
    />
  </FormGroup>
)

export { PasswordInput, Props }
