import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  TextInput
} from '@patternfly/react-core'
import { useState } from 'react'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import { validateSignup } from 'Login/utils/validations'
import { CSRFToken } from 'utilities/CSRFToken'
import { LoginAlert } from 'Login/components/LoginAlert'

import type { IAlert } from 'Types'
import type { FunctionComponent } from 'react'

interface Props {
  alerts: IAlert[];
  path: string;
  user: {
    email: string;
    firstname: string;
    lastname: string;
    username: string;
  };
}

const SignupForm: FunctionComponent<Props> = ({
  alerts,
  path,
  user
}) => {
  const [state, setState] = useState({
    username: user.username,
    email: user.email,
    firstName: user.firstname,
    lastName: user.lastname,
    password: '',
    passwordConfirmation: ''
  })

  const [validationVisibility, setValidationVisibility] = useState({
    username: false,
    email: false,
    firstName: false,
    lastName: false,
    password: false,
    passwordConfirmation: false
  })

  const handleOnChange = (field: keyof typeof state) => {
    return (value: string) => {
      setState(prev => ({ ...prev, [field]: value }))
      setValidationVisibility(prev => ({ ...prev, [field]: false }) )
    }
  }

  const handleOnBlur = (field: keyof typeof state) => {
    return () => {
      setValidationVisibility(prev => ({ ...prev, [field]: true }))
    }
  }

  const validation = validateSignup(state)

  const validated = (Object.keys(state) as (keyof typeof state)[])
    .reduce((obj, key) => ({
      ...obj,
      [key]: (validationVisibility[key] && validation?.[key]) ? 'error' : 'default'
    }), {}) as Record<keyof typeof state, 'default' | 'error' | undefined>

  const alert = alerts.length ? alerts[0] : undefined

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={path}
      id="signup_form"
      method="post"
    >
      <LoginAlert message={alert?.message} type={alert?.type} />

      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_username"
        helperTextInvalid={validation?.username?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Username"
        validated={validated.username}
      >
        <TextInput
          autoFocus
          isRequired
          autoComplete="off"
          id="user_username"
          name="user[username]"
          type="text"
          validated={validated.username}
          value={state.username}
          onBlur={handleOnBlur('username')}
          onChange={handleOnChange('username')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_email"
        helperTextInvalid={validation?.email?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Email address"
        validated={validated.email}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_email"
          name="user[email]"
          type="email"
          validated={validated.email}
          value={state.email}
          onBlur={handleOnBlur('email')}
          onChange={handleOnChange('email')}
        />
      </FormGroup>

      <FormGroup
        autoComplete="off"
        fieldId="user_first_name"
        helperTextInvalid={validation?.firstName?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="First name"
        validated={validated.firstName}
      >
        <TextInput
          autoComplete="off"
          id="user_first_name"
          name="user[first_name]"
          type="text"
          validated={validated.firstName}
          value={state.firstName}
          onBlur={handleOnBlur('firstName')}
          onChange={handleOnChange('firstName')}
        />
      </FormGroup>

      <FormGroup
        autoComplete="off"
        fieldId="user_last_name"
        helperTextInvalid={validation?.lastName?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Last name"
        validated={validated.lastName}
      >
        <TextInput
          autoComplete="off"
          id="user_last_name"
          name="user[last_name]"
          type="text"
          validated={validated.lastName}
          value={state.lastName}
          onBlur={handleOnBlur('lastName')}
          onChange={handleOnChange('lastName')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_password"
        helperTextInvalid={validation?.password?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Password"
        validated={validated.password}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_password"
          name="user[password]"
          type="password"
          validated={validated.password}
          value={state.password}
          onBlur={handleOnBlur('password')}
          onChange={handleOnChange('password')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_password_confirmation"
        helperTextInvalid={validation?.passwordConfirmation?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Password confirmation"
        validated={validated.passwordConfirmation}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_password_confirmation"
          name="user[password_confirmation]"
          type="password"
          validated={validated.passwordConfirmation}
          value={state.passwordConfirmation}
          onBlur={handleOnBlur('passwordConfirmation')}
          onChange={handleOnChange('passwordConfirmation')}
        />
      </FormGroup>

      <ActionGroup>
        <Button
          isBlock
          isDisabled={validation !== undefined}
          name="commit"
          type="submit"
          variant="primary"
        >
          Sign up
        </Button>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { SignupForm }
