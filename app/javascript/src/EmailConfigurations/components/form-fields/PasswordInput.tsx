import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  password: string;
  setPassword: (password: string) => void;
  isRequired?: boolean;
  errors: string[];
}

const PasswordInput: FunctionComponent<Props> = ({
  password,
  setPassword,
  isRequired,
  errors
}) => {
  const validated = errors.length ? 'error' : 'default'
  return (
    <FormGroup
      fieldId="email_configuration_password"
      helperTextInvalid={errors.toString()}
      isRequired={isRequired}
      label="Password"
      validated={validated}
    >
      <TextInput
        autoComplete="new-password"
        id="email_configuration_password"
        name="email_configuration[password]"
        type="password"
        validated={validated}
        value={password}
        onChange={setPassword}
      />
    </FormGroup>
  )
}

export type { Props }
export { PasswordInput }
