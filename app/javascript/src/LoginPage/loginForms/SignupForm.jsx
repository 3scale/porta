// @flow

import React, { Component } from 'react'
import {
  Form,
  ActionGroup,
  Button
} from '@patternfly/react-core'
import {
  HiddenInputs,
  FormGroup
} from 'LoginPage'

type Props = {
  path: string
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
type HandlersProps = {
  handleTextInputUsername: (username: string) => void,
  handleTextInputEmail: (emailAddress: string) => void,
  handleTextInputPassword: (password: string) => void,
  handleTextInputPasswordConfirmation: (passwordConfirmation: string) => void
}

const FormGroups = ({state, handlers}: {state: State, handlers: HandlersProps}) => {
  const {username, isValidUsername, emailAddress, isValidEmailAddress, password, isValidPassword, passwordConfirmation, isValidPasswordConfirmation} = state
  const {handleTextInputUsername, handleTextInputEmail, handleTextInputPassword, handleTextInputPasswordConfirmation} = handlers

  const usernameInputProps = {
    value: username,
    onChange: handleTextInputUsername,
    autoFocus: 'autoFocus',
    inputIsValid: isValidUsername
  }
  const emailInputProps = {
    value: emailAddress,
    onChange: handleTextInputEmail,
    autoFocus: 'autoFocus',
    inputIsValid: isValidEmailAddress
  }
  const passwordInputProps = {
    value: password,
    onChange: handleTextInputPassword,
    ariaInvalid: 'false',
    inputIsValid: isValidPassword
  }
  const passwordConfirmationInputProps = {
    value: passwordConfirmation,
    onChange: handleTextInputPasswordConfirmation,
    ariaInvalid: 'false',
    inputIsValid: isValidPasswordConfirmation
  }

  return (
    <React.Fragment>
      <FormGroup
        type='user[username]'
        labelIsValid={isValidUsername}
        inputProps={usernameInputProps}
      />
      <FormGroup
        type='user[email]'
        labelIsValid={isValidEmailAddress}
        inputProps={emailInputProps}
      />
      <FormGroup
        type='user[password]'
        labelIsValid={isValidPassword}
        inputProps={passwordInputProps}
      />
      <FormGroup
        type='user[password_confirmation]'
        labelIsValid={isValidPasswordConfirmation}
        inputProps={passwordConfirmationInputProps}
      />
    </React.Fragment>
  )
}

class SignupForm extends Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      username: '',
      emailAddress: '',
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
    const formGroupHandlers = {
      handleTextInputUsername: this.handleTextInputUsername,
      handleTextInputEmail: this.handleTextInputEmail,
      handleTextInputPassword: this.handleTextInputPassword,
      handleTextInputPasswordConfirmation: this.handleTextInputPasswordConfirmation
    }
    return (
      <Form
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        <FormGroups state={this.state} handlers={formGroupHandlers}/>
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
