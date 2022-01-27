// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  password: string,
  setPassword: string => void,
  errors: string[]
}

const PasswordRepeatInput = ({ password, setPassword, errors }: Props): React.Node => (
  <FormGroup
    isRequired
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
    />
  </FormGroup>
)

export { PasswordRepeatInput }
