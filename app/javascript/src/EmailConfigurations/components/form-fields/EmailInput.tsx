import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

type Props = {
  email: string,
  setEmail: (email: string) => void,
  isRequired?: boolean,
  errors: string[]
}

const EmailInput: FunctionComponent<Props> = ({
  email,
  setEmail,
  isRequired,
  errors
}) => (
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
