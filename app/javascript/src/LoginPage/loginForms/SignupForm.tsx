import React from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'
import { TextField, EmailField, PasswordField } from 'LoginPage/loginForms/FormGroups'
import { HiddenInputs } from 'LoginPage/loginForms/HiddenInputs'
import { validateSingleField } from 'LoginPage/utils/formValidation'

import type { ReactNode } from 'react'
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

// eslint-disable-next-line react/require-optimization -- TODO: resolve this react/require-optimization
class SignupForm extends React.Component<Props, State> {
  public constructor (props: Props) {
    super(props)
    this.state = {
      [INPUT_NAMES.username]: this.props.user.username,
      [INPUT_NAMES.email]: this.props.user.email,
      [INPUT_NAMES.firstName]: this.props.user.firstname,
      [INPUT_NAMES.lastName]: this.props.user.lastname,
      [INPUT_NAMES.password]: '',
      [INPUT_NAMES.passwordConfirmation]: '',
      validation: {
        [INPUT_NAMES.username]: this.props.user.username ? true : undefined,
        [INPUT_NAMES.email]: this.props.user.email ? true : undefined,
        [INPUT_NAMES.firstName]: true,
        [INPUT_NAMES.lastName]: true,
        [INPUT_NAMES.password]: undefined,
        [INPUT_NAMES.passwordConfirmation]: undefined
      }
    } as State
  }

  private readonly getInputProps = (name: InputType, isRequired: boolean): InputProps => ({
    isRequired,
    name: INPUT_NAMES[name],
    fieldId: INPUT_IDS[name],
    label: INPUT_LABELS[name],
    isValid: this.state.validation[INPUT_NAMES[name]],
    value: this.state[INPUT_NAMES[name]],
    onChange: this.handleInputChange
  })

  private readonly handleInputChange: (value: string, event: React.SyntheticEvent<HTMLInputElement>) => void = (value, event) => {
    const isValid = event.currentTarget.required ? validateSingleField(event) : true

    this.setState((prevState: State) => {
      const validation = {
        ...prevState.validation,
        [event.currentTarget.name]: isValid
      } as const

      return {
        [event.currentTarget.name]: value,
        validation
      } as State
    })
  }

  // eslint-disable-next-line @typescript-eslint/member-ordering
  public render (): ReactNode {
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)

    const usernameInputProps = this.getInputProps('username', true)
    const emailInputProps = this.getInputProps('email', true)
    const firstNameInputProps = this.getInputProps('firstName', false)
    const lastNameInputProps = this.getInputProps('lastName', false)
    const passwordInputProps = this.getInputProps('password', true)
    const passwordConfirmationInputProps = this.getInputProps('passwordConfirmation', true)

    return (
      <Form
        noValidate
        acceptCharset="UTF-8"
        action={this.props.path}
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
}

export { SignupForm, Props }
