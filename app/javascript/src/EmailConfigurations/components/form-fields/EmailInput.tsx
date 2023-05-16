import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  email: string;
  setEmail: (email: string) => void;
  isRequired?: boolean;
  errors: string[];
}

const EmailInput: FunctionComponent<Props> = ({
  email,
  setEmail,
  isRequired,
  errors
}) => {
  const validated = errors.length ? 'error' : 'default'
  return (
    <FormGroup
      fieldId="email_configuration_email"
      helperTextInvalid={errors.toString()}
      isRequired={isRequired}
      label="Email"
      validated={validated}
    >
      <TextInput
        id="email_configuration_email"
        name="email_configuration[email]"
        type="text"
        validated={validated}
        value={email}
        onChange={setEmail}
      />
    </FormGroup>
  )
}

export type { Props }
export { EmailInput }
