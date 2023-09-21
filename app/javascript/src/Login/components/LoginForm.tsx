import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  TextInput
} from '@patternfly/react-core'

import { validateLogin } from 'Login/utils/validations'
import { CSRFToken } from 'utilities/CSRFToken'
import { LoginAlert } from 'Login/components/FormAlert'

import type { FlashMessage } from 'Types/FlashMessages'
import type { FunctionComponent } from 'react'

interface Props {
  error?: FlashMessage;
  providerSessionsPath: string;
  session: {
    username: string | null;
  };
}

const LoginForm: FunctionComponent<Props> = ({
  error,
  providerSessionsPath,
  session
}) => {
  const [state, setState] = useState({
    username: session.username ?? '',
    password: ''
  })
  const [validationVisibility, setValidationVisibility] = useState({
    username: false,
    password: false
  })

  const handleOnChange = (field: keyof typeof state) => {
    return (value: string) => {
      setState(prev => ({ ...prev, [field]: value }))
      setValidationVisibility(prev => ({ ...prev, [field]: false }))
    }
  }

  const handleOnBlur = (field: keyof typeof state) => {
    return () => {
      setValidationVisibility(prev => ({ ...prev, [field]: true }))
    }
  }

  const validation = validateLogin(state)

  const usernameErrors = validation?.username
  const passwordErrors = validation?.password

  const usernameValidated = (validationVisibility.username && usernameErrors) ? 'error' : 'default'
  const passwordValidated = (validationVisibility.password && passwordErrors) ? 'error' : 'default'

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={providerSessionsPath}
      autoComplete="off"
      id="new_session"
      method="post"
    >
      <LoginAlert error={error} />

      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="session_username"
        helperTextInvalid={usernameErrors?.[0]}
        label="Email or Username"
        validated={usernameValidated}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="session_username"
          name="username"
          type="email"
          validated={usernameValidated}
          value={state.username}
          onBlur={handleOnBlur('username')}
          onChange={handleOnChange('username')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="session_password"
        helperTextInvalid={passwordErrors?.[0]}
        label="Password"
        validated={passwordValidated}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="session_password"
          name="password"
          type="password"
          validated={passwordValidated}
          value={state.password}
          onBlur={handleOnBlur('password')}
          onChange={handleOnChange('password')}
        />
      </FormGroup>

      <ActionGroup>
        <Button
          isBlock
          isDisabled={validation !== undefined}
          type="submit"
          variant="primary"
        >
          Sign in
        </Button>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { LoginForm }
