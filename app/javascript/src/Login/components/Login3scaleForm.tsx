import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'

import { TextField, PasswordField } from 'Login/components/FormGroups'
import { HiddenInputs } from 'Login/components/HiddenInputs'
import { validateSingleField } from 'Login/utils/formValidation'

import type { FunctionComponent } from 'react'

interface Props {
  providerSessionsPath: string;
  session: {
    username: string | null | undefined;
  };
}

interface State {
  username: string;
  password: string;
  validation: {
    username?: boolean;
    password?: boolean;
  };
}

const USERNAME_ATTRS = {
  name: 'username',
  fieldId: 'session_username',
  label: 'Email or Username'
}

const PASSWORD_ATTRS = {
  name: 'password',
  fieldId: 'session_password',
  label: 'Password'
}

const Login3scaleForm: FunctionComponent<Props> = (props) => {
  const [state, setState] = useState<State>({
    username: props.session.username ?? '',
    password: '',
    validation: {
      username: props.session.username ? true : undefined,
      password: undefined
    }
  })

  const handleInputChange: (value: string, event: React.SyntheticEvent<HTMLInputElement>) => void = (value, event) => {
    const isValid = validateSingleField(event)
    const validation = {
      // eslint-disable-next-line react/no-access-state-in-setstate -- FIXME: properly type this method
      ...state.validation,
      [event.currentTarget.name]: isValid
    }
    setState({
      [event.currentTarget.name]: value,
      validation
    } as unknown as State)
  }

  const { username, password, validation } = state
  const usernameInputProps = {
    isRequired: true,
    name: USERNAME_ATTRS.name,
    fieldId: USERNAME_ATTRS.fieldId,
    label: USERNAME_ATTRS.label,
    isValid: validation.username,
    value: username,
    onChange: handleInputChange,
    autoFocus: !username
  } as const
  const passwordInputProps = {
    isRequired: true,
    name: PASSWORD_ATTRS.name,
    fieldId: PASSWORD_ATTRS.fieldId,
    label: PASSWORD_ATTRS.label,
    isValid: validation.password,
    value: password,
    onChange: handleInputChange,
    autoFocus: Boolean(username)
  } as const
  const formDisabled = Object.values(state.validation).some(value => !value)
  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={props.providerSessionsPath}
      autoComplete="off"
      id="new_session"
      method="post"
    >
      <HiddenInputs />
      <TextField inputProps={usernameInputProps} />
      <PasswordField inputProps={passwordInputProps} />
      <ActionGroup>
        <Button
          className="pf-c-button pf-m-primary pf-m-block"
          isDisabled={formDisabled}
          type="submit"
        > Sign in
        </Button>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { Login3scaleForm }
