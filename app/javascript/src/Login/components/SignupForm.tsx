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
import { LoginAlert } from 'Login/components/FormAlert'

import type { FlashMessage } from 'Types'
import type { FunctionComponent } from 'react'

interface Props {
  path: string;
  user: {
    email: string;
    firstname: string;
    lastname: string;
    username: string;
    errors: FlashMessage[];
  };
}

const SignupForm: FunctionComponent<Props> = ({
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

  const validation = validateSignup(state)

  const usernameErrors = validation?.username
  const emailErrors = validation?.email
  const firstNameErrors = validation?.firstName
  const lastNameErrors = validation?.lastName
  const passwordErrors = validation?.password
  const passwordConfirmationErrors = validation?.passwordConfirmation

  const validatedUsername = (validationVisibility.username && usernameErrors) ? 'error' : 'default'
  const validatedEmail = (validationVisibility.email && emailErrors) ? 'error' : 'default'
  const validatedFirstName = (validationVisibility.firstName && firstNameErrors) ? 'error' : 'default'
  const validatedLastName = (validationVisibility.lastName && lastNameErrors) ? 'error' : 'default'
  const validatedPassword = (validationVisibility.password && passwordErrors) ? 'error' : 'default'
  const validatedPasswordConfirmation = (validationVisibility.passwordConfirmation && passwordConfirmationErrors) ? 'error' : 'default'

  const error = user.errors.length ? user.errors[0] : undefined

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={path}
      id="signup_form"
      method="post"
    >
      <LoginAlert error={error} />

      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_username"
        helperTextInvalid={usernameErrors?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Username"
        validated={validatedUsername}
      >
        <TextInput
          autoFocus
          isRequired
          autoComplete="off"
          id="user_username"
          name="user[username]"
          type="text"
          validated={validatedUsername}
          value={state.username}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, username: true })) }}
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
        validated={validatedEmail}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_email"
          name="user[email]"
          type="email"
          validated={validatedEmail}
          value={state.email}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, email: true })) }}
          onChange={handleOnChange('email')}
        />
      </FormGroup>

      <FormGroup
        autoComplete="off"
        fieldId="user_first_name"
        helperTextInvalid={firstNameErrors?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="First name"
        validated={validatedFirstName}
      >
        <TextInput
          autoComplete="off"
          id="user_first_name"
          name="user[first_name]"
          type="text"
          validated={validatedFirstName}
          value={state.firstName}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, firstName: true })) }}
          onChange={handleOnChange('firstName')}
        />
      </FormGroup>

      <FormGroup
        autoComplete="off"
        fieldId="user_last_name"
        helperTextInvalid={lastNameErrors?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Last name"
        validated={validatedLastName}
      >
        <TextInput
          autoComplete="off"
          id="user_last_name"
          name="user[last_name]"
          type="text"
          validated={validatedLastName}
          value={state.lastName}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, lastName: true })) }}
          onChange={handleOnChange('lastName')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_password"
        helperTextInvalid={passwordErrors?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Password"
        validated={validatedPassword}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_password"
          name="user[password]"
          type="password"
          validated={validatedPassword}
          value={state.password}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, password: true })) }}
          onChange={handleOnChange('password')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_password_confirmation"
        helperTextInvalid={passwordConfirmationErrors?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Password confirmation"
        validated={validatedPasswordConfirmation}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_password_confirmation"
          name="user[password_confirmation]"
          type="password"
          validated={validatedPasswordConfirmation}
          value={state.passwordConfirmation}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, passwordConfirmation: true })) }}
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
