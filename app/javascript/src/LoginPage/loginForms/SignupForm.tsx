import * as React from 'react';
import {
  Form,
  ActionGroup,
  Button
} from '@patternfly/react-core'
import {
  HiddenInputs,
  TextField,
  PasswordField,
  EmailField,
  validateSingleField
} from 'LoginPage'
import type {SignupProps, InputProps} from 'Types'

type Validation = {
  [key: string]: boolean | undefined
};

type State = {
  ['user[username]']: string,
  ['user[email]']: string,
  ['user[first_name]']: string,
  ['user[last_name]']: string,
  ['user[password]']: string,
  ['user[password_confirmation]']: string,
  ['validation']: Validation
};

const INPUT_NAMES = {
  username: 'user[username]',
  email: 'user[email]',
  firstName: 'user[first_name]',
  lastName: 'user[last_name]',
  password: 'user[password]',
  passwordConfirmation: 'user[password_confirmation]'
} as const

const INPUT_IDS = {
  username: 'user_username',
  email: 'user_email',
  firstName: 'user_first_name',
  lastName: 'user_last_name',
  password: 'user_password',
  passwordConfirmation: 'user_password_confirmation'
} as const

const INPUT_LABELS = {
  username: 'Username',
  email: 'Email address',
  firstName: 'First name',
  lastName: 'Last name',
  password: 'Password',
  passwordConfirmation: 'Password confirmation'
} as const

class SignupForm extends React.Component<SignupProps, State> {
  state: State = {
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
  };

  getInputProps: (arg1: string, arg2: boolean) => InputProps = (name, isRequired) => {
    return {
      isRequired,
      name: INPUT_NAMES[name],
      fieldId: INPUT_IDS[name],
      label: INPUT_LABELS[name],
      isValid: this.state.validation[INPUT_NAMES[name]],
      value: this.state[INPUT_NAMES[name]],
      onChange: this.handleInputChange
    }
  };

  handleInputChange: (arg1: string, arg2: React.SyntheticEvent<HTMLInputElement>) => void = (value, event) => {
    const isValid = event.currentTarget.required ? validateSingleField(event) : true
    const validation = {
      ...this.state.validation,
      [event.currentTarget.name]: isValid
    } as const

    this.setState({
      [event.currentTarget.name]: value,
      validation
    })
  };

  render(): React.ReactElement {
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)

    const usernameInputProps = this.getInputProps('username', true)
    const emailInputProps = this.getInputProps('email', true)
    const firstNameInputProps = this.getInputProps('firstName', false)
    const lastNameInputProps = this.getInputProps('lastName', false)
    const passwordInputProps = this.getInputProps('password', true)
    const passwordConfirmationInputProps = this.getInputProps('passwordConfirmation', true)

    return (
      <Form noValidate
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        <TextField inputProps={usernameInputProps}/>
        <EmailField inputProps={emailInputProps}/>
        <TextField inputProps={firstNameInputProps}/>
        <TextField inputProps={lastNameInputProps}/>
        <PasswordField inputProps={passwordInputProps}/>
        <PasswordField inputProps={passwordConfirmationInputProps}/>

        <ActionGroup>
          <Button className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            name="commit"
            isDisabled={formDisabled}
          >Sign up</Button>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  SignupForm
}
