// @flow

import React, { Component } from 'react'
import {
  Form,
  ActionGroup
} from '@patternfly/react-core'
import {
  HiddenInputs,
  FormGroup
} from 'LoginPage'

type Props = {
  path: string,
  email: string
}

type State = {
  username: string,
  emailAddress: string,
  password: string,
  passwordConfirmation: string,
  isValidUsername: ?boolean,
  isValidEmailAddress: ?boolean,
  isValidPassword: ?boolean,
  isValidPasswordConfirmation: ?boolean
}

const InputFormGroup = (props) => {
  const {type, value, onChange, isValid} = props
  const inputProps = {
    value,
    onChange,
    isValid
  }
  return (
    <FormGroup
      type={type}
      labelIsValid={isValid}
      inputProps={inputProps}
    />
  )
}

class SignupForm extends Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      username: '',
      emailAddress: this.props.email,
      password: '',
      passwordConfirmation: '',
      isValidUsername: undefined,
      isValidEmailAddress: undefined,
      isValidPassword: undefined,
      isValidPasswordConfirmation: undefined
    }
  }

  setIsValidUsername = () => this.setState({ isValidUsername: this.state.username !== '' })

  handleTextInputUsername = (username: string) => this.setState({ username }, this.setIsValidUsername)

  setIsValidEmail = () => this.setState({ isValidEmailAddress: this.state.emailAddress !== '' })

  handleTextInputEmail = (emailAddress: string) => this.setState({ emailAddress }, this.setIsValidEmail)

  setIsValidPassword = () => this.setState({ isValidPassword: this.state.password !== '' })

  handleTextInputPassword = (password: string) => this.setState({ password }, this.setIsValidPassword)

  setIsValidPasswordConfirmation = () => this.setState({ isValidPasswordConfirmation: this.state.passwordConfirmation !== '' })

  handleTextInputPasswordConfirmation = (passwordConfirmation: string) => this.setState({ passwordConfirmation }, this.setIsValidPasswordConfirmation)

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    this.setIsValidUsername()
    this.setIsValidPassword()
    const isFormDisabled =
      this.state.username === '' ||
      this.state.emailAddress === '' ||
      this.state.password === '' ||
      this.state.passwordConfirmation === '' ||
      this.state.passwordConfirmation !== this.state.password ||
      this.state.isValidUsername === false ||
      this.state.isValidEmailAddress === false ||
      this.state.isValidPassword === false ||
      this.state.isValidPasswordConfirmation === false
    if (isFormDisabled) {
      event.preventDefault()
    }
  }

  render () {
    const { username, isValidUsername, emailAddress, isValidEmailAddress, password, isValidPassword, passwordConfirmation, isValidPasswordConfirmation } = this.state
    return (
      <Form
        noValidate={false}
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        <InputFormGroup type='user[username]' value={username} isValid={isValidUsername} onChange={this.handleTextInputUsername} />
        <InputFormGroup type='user[email]' value={emailAddress} isValid={isValidEmailAddress} onChange={this.handleTextInputEmail} />
        <InputFormGroup type='user[password]' value={password} isValid={isValidPassword} onChange={this.handleTextInputPassword} />
        <InputFormGroup type='user[password_confirmation]' value={passwordConfirmation} isValid={isValidPasswordConfirmation} onChange={this.handleTextInputPasswordConfirmation} />
        <ActionGroup>
          <input
            type="submit"
            name="commit"
            value="Sign up"
            className="user-signup pf-c-button pf-m-primary pf-c-button pf-m-primary pf-m-block"
          />
        </ActionGroup>
      </Form>
    )
  }
}

export {
  SignupForm
}
