import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  HelperText,
  HelperTextItem,
  TextInput
} from '@patternfly/react-core'

import { validateLogin } from 'Login/utils/validations'
import { CSRFToken } from 'utilities/CSRFToken'

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
  const [username, setUsername] = useState(session.username ?? '')
  const [password, setPassword] = useState('')
  const [validationVisibility, setValidationVisibility] = useState({
    username: false,
    password: false
  })

  const onUsernameChange = (value: string) => {
    setUsername(value)
    setValidationVisibility(prev => ({ ...prev, username: false }))
  }

  const onPasswordChange = (value: string) => {
    setPassword(value)
    setValidationVisibility(prev => ({ ...prev, password: false }))
  }

  const validation = validateLogin({ username, password })

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={providerSessionsPath}
      autoComplete="off"
      id="new_session"
      method="post"
    >
      <HelperText className={error ? '' : 'invisible'}>
        <HelperTextItem hasIcon={error?.type === 'error'} variant={error?.type as 'error'}>
          {error?.message}
        </HelperTextItem>
      </HelperText>

      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="session_username"
        helperTextInvalid={validation?.username?.[0]}
        label="Email or Username"
        validated={(validationVisibility.username && validation?.username) ? 'error' : 'default'}
      >
        <TextInput
          isRequired
          autoComplete="off"
          autoFocus={!username}
          id="session_username"
          name="username"
          type="email"
          validated={(validationVisibility.username && validation?.username) ? 'error' : 'default'}
          value={username}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, username: true })) }}
          onChange={onUsernameChange}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="session_password"
        helperTextInvalid={validation?.password?.[0]}
        label="Password"
        validated={(validationVisibility.password && validation?.password) ? 'error' : 'default'}
      >
        <TextInput
          isRequired
          autoComplete="off"
          autoFocus={Boolean(username)}
          id="session_password"
          name="password"
          type="password"
          validated={(validationVisibility.password && validation?.password) ? 'error' : 'default'}
          value={password}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, password: true })) }}
          onChange={onPasswordChange}
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
