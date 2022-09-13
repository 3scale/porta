import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  email: string,
  setEmail: (arg1: string) => void,
  isRequired?: boolean,
  errors: string[]
};

const EmailInput = (
  {
    email,
    setEmail,
    isRequired,
    errors
  }: Props
): React.ReactElement => <FormGroup
  isRequired={isRequired}
  label="Email"
  validated="default"
  fieldId="email_configuration_email"
  isValid={!errors.length}
  helperTextInvalid={errors.toString()}
>
  <TextInput
    type="text"
    id="email_configuration_email"
    name="email_configuration[email]"
    value={email}
    onChange={setEmail}
    isValid={!errors.length}
  />
</FormGroup>

export { EmailInput }
