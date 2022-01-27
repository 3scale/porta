// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  password: string,
  setPassword: string => void,
  errors: string[]
}

const PasswordInput = ({ password, setPassword, errors }: Props): React.Node => (
  <FormGroup
    isRequired
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
    />
  </FormGroup>
)

export { PasswordInput }
