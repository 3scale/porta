import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'

import { TextField, PasswordField } from 'Login/components/FormGroups'
import { HiddenInputs } from 'Login/components/HiddenInputs'
import { validateSingleField } from 'Login/utils/formValidation'

import type { FunctionComponent, FormEvent } from 'react'

interface Props {
  providerSessionsPath: string;
  session: {
    username: string | null | undefined;
  };
}

const Login3scaleForm: FunctionComponent<Props> = (props) => {
  // eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing -- TODO: make it either undefined or null
  const [username, setUsername] = useState(props.session.username || '')
  const [password, setPassword] = useState('')
  const [validation, setValidation] = useState({
    username: undefined as boolean | undefined,
    password: undefined as boolean | undefined
  })

  // TODO: validations should happen on loss focus or sibmission
  const onUsernameChange = (value: string, event: FormEvent<HTMLInputElement>) => {
    const { currentTarget } = event
    setUsername(value)
    setValidation(prev => ({ ...prev, username: validateSingleField(currentTarget) }))
  }

  const onPasswordChange = (value: string, event: FormEvent<HTMLInputElement>) => {
    const { currentTarget } = event
    setPassword(value)
    setValidation(prev => ({ ...prev, password: validateSingleField(currentTarget) }))
  }

  const formDisabled = Object.values(validation).some(value => !value)
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
      <TextField inputProps={{
        isRequired: true,
        name: 'username',
        fieldId: 'session_username',
        label: 'Email or Username',
        isValid: validation.username,
        value: username,
        onChange: onUsernameChange,
        autoFocus: !username
      }}
      />
      <PasswordField inputProps={{
        isRequired: true,
        name: 'password',
        fieldId: 'session_password',
        label: 'Password',
        isValid: validation.password,
        value: password,
        onChange: onPasswordChange,
        autoFocus: Boolean(username)
      }}
      />
      <ActionGroup>
        <Button
          className="pf-c-button pf-m-primary pf-m-block"
          isDisabled={formDisabled}
          type="submit"
        >
          Sign in
        </Button>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { Login3scaleForm }
