
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  userName: string,
  setUserName: (arg1: string) => void,
  isRequired?: boolean,
  errors: string[]
}

const UserNameInput = (
  {
    userName,
    setUserName,
    isRequired,
    errors
  }: Props
): React.ReactElement => (
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
