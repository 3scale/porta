
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  userName: string,
  setUserName: (arg1: string) => void,
  isRequired?: boolean,
  errors: string[]
};

const UserNameInput = (
  {
    userName,
    setUserName,
    isRequired,
    errors
  }: Props
): React.ReactElement => <FormGroup
  isRequired={isRequired}
  label="Username"
  validated="default"
  fieldId="email_configuration_user_name"
  isValid={!errors.length}
  helperTextInvalid={errors.toString()}
>
  <TextInput
    type="text"
    id="email_configuration_user_name"
    name="email_configuration[user_name]"
    value={userName}
    onChange={setUserName}
    isValid={!errors.length}
  />
</FormGroup>

export { UserNameInput, Props }
