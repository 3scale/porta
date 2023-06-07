import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'

import { TextField, EmailField, PasswordField } from 'Login/components/FormGroups'
import { HiddenInputs } from 'Login/components/HiddenInputs'
import { validateSingleField } from 'Login/utils/formValidation'

import type { FunctionComponent } from 'react'
import type { InputProps, InputType, SignupProps as Props } from 'Types'

type InputNames = 'user[email]' | 'user[first_name]' | 'user[last_name]' | 'user[password_confirmation]' | 'user[password]' | 'user[username]'

type Validation = Record<InputNames, boolean | undefined>

type State = Record<InputNames, string> & { validation: Validation }

const INPUT_NAMES: Record<InputType, InputNames> = {
  username: 'user[username]',
  email: 'user[email]',
  firstName: 'user[first_name]',
  lastName: 'user[last_name]',
  password: 'user[password]',
  passwordConfirmation: 'user[password_confirmation]'
} as const

const INPUT_IDS: Record<InputType, string> = {
  username: 'user_username',
  email: 'user_email',
  firstName: 'user_first_name',
  lastName: 'user_last_name',
  password: 'user_password',
  passwordConfirmation: 'user_password_confirmation'
} as const

const INPUT_LABELS: Record<InputType, string> = {
  username: 'Username',
  email: 'Email address',
  firstName: 'First name',
  lastName: 'Last name',
  password: 'Password',
  passwordConfirmation: 'Password confirmation'
} as const

const SignupForm: FunctionComponent<Props> = (props) => {
  const [state, setState] = useState({
    [INPUT_NAMES.username]: props.user.username,
    [INPUT_NAMES.email]: props.user.email,
    [INPUT_NAMES.firstName]: props.user.firstname,
    [INPUT_NAMES.lastName]: props.user.lastname,
    [INPUT_NAMES.password]: '',
    [INPUT_NAMES.passwordConfirmation]: '',
    validation: {
      [INPUT_NAMES.username]: props.user.username ? true : undefined,
      [INPUT_NAMES.email]: props.user.email ? true : undefined,
      [INPUT_NAMES.firstName]: true,
      [INPUT_NAMES.lastName]: true,
      [INPUT_NAMES.password]: undefined,
      [INPUT_NAMES.passwordConfirmation]: undefined
    }
  } as State)

  const getInputProps = (name: InputType, isRequired: boolean): InputProps => ({
    isRequired,
    name: INPUT_NAMES[name],
    fieldId: INPUT_IDS[name],
    label: INPUT_LABELS[name],
    isValid: state.validation[INPUT_NAMES[name]],
    value: state[INPUT_NAMES[name]],
    onChange: handleInputChange
  })

  const handleInputChange: (value: string, event: React.SyntheticEvent<HTMLInputElement>) => void = (value, event) => {
    const isValid = event.currentTarget.required ? validateSingleField(event) : true
    const validation = {
      // eslint-disable-next-line react/no-access-state-in-setstate -- FIXME
      ...state.validation,
      [event.currentTarget.name]: isValid
    }

    setState({
      [event.currentTarget.name]: value,
      validation
    } as State)
  }

  const formDisabled = Object.values(state.validation).some(value => value !== true)

  const usernameInputProps = getInputProps('username', true)
  const emailInputProps = getInputProps('email', true)
  const firstNameInputProps = getInputProps('firstName', false)
  const lastNameInputProps = getInputProps('lastName', false)
  const passwordInputProps = getInputProps('password', true)
  const passwordConfirmationInputProps = getInputProps('passwordConfirmation', true)

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={props.path}
      id="signup_form"
      method="post"
    >
      <HiddenInputs />
      <TextField inputProps={usernameInputProps} />
      <EmailField inputProps={emailInputProps} />
      <TextField inputProps={firstNameInputProps} />
      <TextField inputProps={lastNameInputProps} />
      <PasswordField inputProps={passwordInputProps} />
      <PasswordField inputProps={passwordConfirmationInputProps} />

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
