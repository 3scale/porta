import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'
import { useState } from 'react'

import { TextField, EmailField, PasswordField } from 'Login/components/FormGroups'
import { HiddenInputs } from 'Login/components/HiddenInputs'
import { validateSingleField } from 'Login/utils/formValidation'

import type { FormEvent, FunctionComponent } from 'react'
import type { SignupProps as Props } from 'Types'

const SignupForm: FunctionComponent<Props> = (props) => {
  const [username, setUsername] = useState(props.user.username)
  const [email, setEmail] = useState(props.user.email)
  const [firstName, setFirstName] = useState(props.user.firstname)
  const [lastName, setLastName] = useState(props.user.lastname)
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')

  const [validation, setValidation] = useState({
    username: props.user.username ? true : undefined,
    email: props.user.email ? true : undefined,
    firstName: true,
    lastName: true,
    password: undefined as boolean | undefined,
    passwordConfirmation: undefined as boolean | undefined
  })

  // TODO: validations should happen on loss focus or sibmission
  const onUsernameChange = (value: string, event: FormEvent<HTMLInputElement>) => {
    const { currentTarget } = event
    setUsername(value)
    setValidation(prev => ({ ...prev, username: validateSingleField(currentTarget) }) )
  }

  const onEmailChange = (value: string, event: FormEvent<HTMLInputElement>) => {
    const { currentTarget } = event
    setEmail(value)
    setValidation(prev => ({ ...prev, email: validateSingleField(currentTarget) }) )
  }

  const onPasswordChange = (value: string, event: FormEvent<HTMLInputElement>) => {
    const { currentTarget } = event
    setPassword(value)
    setValidation(prev => ({ ...prev, password: validateSingleField(currentTarget) }) )
  }

  const onPasswordConfirmationChange = (value: string, event: FormEvent<HTMLInputElement>) => {
    const { currentTarget } = event
    setPasswordConfirmation(value)
    setValidation(prev => ({ ...prev, passwordConfirmation: validateSingleField(currentTarget) }) )
  }

  const formDisabled = Object.values(validation).some(value => value !== true)

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={props.path}
      id="signup_form"
      method="post"
    >
      <HiddenInputs />
      <TextField inputProps={{
        isRequired: true,
        name: 'user[username]',
        fieldId: 'user_username',
        label: 'Username',
        isValid: validation.username,
        value: username,
        onChange: onUsernameChange
      }}
      />

      <EmailField inputProps={{
        isRequired: true,
        name: 'user[email]',
        fieldId: 'user_email',
        label: 'Email address',
        isValid: validation.email,
        value: email,
        onChange: onEmailChange
      }}
      />

      <TextField inputProps={{
        name: 'user[first_name]',
        fieldId: 'user_first_name',
        label: 'First name',
        isValid: validation.firstName,
        value: firstName,
        onChange: setFirstName
      }}
      />

      <TextField inputProps={{
        name: 'user[last_name]',
        fieldId: 'user_last_name',
        label: 'Last name',
        isValid: validation.lastName,
        value: lastName,
        onChange: setLastName
      }}
      />

      <PasswordField inputProps={{
        isRequired: true,
        name: 'user[password]',
        fieldId: 'user_password',
        label: 'Password',
        isValid: validation.password,
        value: password,
        onChange: onPasswordChange
      }}
      />

      <PasswordField inputProps={{
        isRequired: true,
        name: 'user[password_confirmation]',
        fieldId: 'user_password_confirmation',
        label: 'Password confirmation',
        isValid: validation.passwordConfirmation,
        value: passwordConfirmation,
        onChange: onPasswordConfirmationChange
      }}
      />

      <ActionGroup>
        <Button
          className="pf-c-button pf-m-primary pf-m-block"
          isDisabled={formDisabled}
          name="commit"
          type="submit"
        >
          Sign up
        </Button>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { SignupForm }
