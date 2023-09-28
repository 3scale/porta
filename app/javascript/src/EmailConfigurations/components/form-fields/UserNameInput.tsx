import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  userName: string;
  setUserName: (userName: string) => void;
  isRequired?: boolean;
  errors: string[];
}

const UserNameInput: FunctionComponent<Props> = ({
  userName,
  setUserName,
  isRequired,
  errors
}) => {
  const validated = errors.length ? 'error' : 'default'
  return (
    <FormGroup
      fieldId="email_configuration_user_name"
      helperTextInvalid={errors.toString()}
      isRequired={isRequired}
      label="Username"
      validated={validated}
    >
      <TextInput
        id="email_configuration_user_name"
        name="email_configuration[user_name]"
        type="text"
        validated={validated}
        value={userName}
        onChange={setUserName}
      />
    </FormGroup>
  )
}

export type { Props }
export { UserNameInput }
