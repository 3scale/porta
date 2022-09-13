import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  password: string,
  setPassword: (arg1: string) => void,
  isRequired?: boolean,
  errors: string[]
};

const PasswordInput = (
  {
    password,
    setPassword,
    isRequired,
    errors
  }: Props
): React.ReactElement => <FormGroup
  isRequired={isRequired}
  label="Password"
  validated="default"
  fieldId="email_configuration_password"
  isValid={!errors.length}
  helperTextInvalid={errors.toString()}
>
  <TextInput
    type="password"
    id="email_configuration_password"
    name="email_configuration[password]"
    value={password}
    onChange={setPassword}
    isValid={!errors.length}
    autoComplete="new-password"
  />
</FormGroup>

export { PasswordInput }
