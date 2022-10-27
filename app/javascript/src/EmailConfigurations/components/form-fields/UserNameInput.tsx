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
}) => (
  <FormGroup
    fieldId="email_configuration_user_name"
    helperTextInvalid={errors.toString()}
    isRequired={isRequired}
    isValid={!errors.length}
    label="Username"
    validated="default"
  >
    <TextInput
      id="email_configuration_user_name"
      isValid={!errors.length}
      name="email_configuration[user_name]"
      type="text"
      value={userName}
      onChange={setUserName}
    />
  </FormGroup>
)

export { UserNameInput, Props }
