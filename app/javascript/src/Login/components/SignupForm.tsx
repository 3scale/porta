import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  HelperText,
  HelperTextItem,
  TextInput
} from '@patternfly/react-core'
import { useState } from 'react'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import { validateSignup } from 'Login/utils/validations'
import { CSRFToken } from 'utilities/CSRFToken'

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

  const error = user.errors.length ? user.errors[0] : undefined

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={path}
      id="signup_form"
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
        fieldId="user_username"
        helperTextInvalid={validationVisibility.username && validation?.username?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Username"
        validated={(validationVisibility.username && validation?.username) ? 'error' : 'default'}
      >
        <TextInput
          autoFocus
          isRequired
          autoComplete="off"
          id="user_username"
          name="user[username]"
          type="text"
          validated={(validationVisibility.username && validation?.username) ? 'error' : 'default'}
          value={state.username}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, username: true })) }}
          onChange={handleOnChange('username')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_email"
        helperTextInvalid={validationVisibility.email && validation?.email?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Email address"
        validated={(validationVisibility.email && validation?.email) ? 'error' : 'default'}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_email"
          name="user[email]"
          type="email"
          validated={(validationVisibility.email && validation?.email) ? 'error' : 'default'}
          value={state.email}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, email: true })) }}
          onChange={handleOnChange('email')}
        />
      </FormGroup>

      <FormGroup
        autoComplete="off"
        fieldId="user_first_name"
        helperTextInvalid={validationVisibility.username && validation?.username?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="First name"
        validated={(validationVisibility.firstName && validation?.firstName) ? 'error' : 'default'}
      >
        <TextInput
          autoComplete="off"
          id="user_first_name"
          name="user[first_name]"
          type="text"
          validated={(validationVisibility.firstName && validation?.firstName) ? 'error' : 'default'}
          value={state.firstName}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, firstName: true })) }}
          onChange={handleOnChange('firstName')}
        />
      </FormGroup>

      <FormGroup
        autoComplete="off"
        fieldId="user_last_name"
        helperTextInvalid={validationVisibility.lastName && validation?.lastName?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Last name"
        validated={(validationVisibility.lastName && validation?.lastName) ? 'error' : 'default'}
      >
        <TextInput
          autoComplete="off"
          id="user_last_name"
          name="user[last_name]"
          type="text"
          validated={(validationVisibility.lastName && validation?.lastName) ? 'error' : 'default'}
          value={state.lastName}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, lastName: true })) }}
          onChange={handleOnChange('lastName')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_password"
        helperTextInvalid={validationVisibility.password && validation?.password?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Password"
        validated={(validationVisibility.password && validation?.password) ? 'error' : 'default'}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_password"
          name="user[password]"
          type="password"
          validated={(validationVisibility.password && validation?.password) ? 'error' : 'default'}
          value={state.password}
          onBlur={() => { setValidationVisibility(prev => ({ ...prev, password: true })) }}
          onChange={handleOnChange('password')}
        />
      </FormGroup>

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="user_password_confirmation"
        helperTextInvalid={validationVisibility.passwordConfirmation && validation?.passwordConfirmation?.[0]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Password confirmation"
        validated={(validationVisibility.passwordConfirmation && validation?.passwordConfirmation) ? 'error' : 'default'}
      >
        <TextInput
          isRequired
          autoComplete="off"
          id="user_password_confirmation"
          name="user[password_confirmation]"
          type="password"
          validated={(validationVisibility.passwordConfirmation && validation?.passwordConfirmation) ? 'error' : 'default'}
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
