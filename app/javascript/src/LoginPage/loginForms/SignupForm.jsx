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
import { validateFormFields } from 'utilities/formValidation'

type Props = {
  path: string,
  user: {
    email: string,
    username: string,
    firstname: string,
    lastname: string
  }
}

type State = {
  username: string,
  emailAddress: string,
  firstname: string,
  lastname: string,
  password: string,
  passwordConfirmation: string,
  isValidUsername: ?boolean,
  isValidEmailAddress: ?boolean,
  isValidFirstname: boolean,
  isValidLastname: boolean,
  isValidPassword: ?boolean,
  isValidPasswordConfirmation: ?boolean
}

const InputFormGroup = (props) => {
  const { isRequired, type, value, onChange, isValid } = props
  const inputProps = {
    value,
    onChange,
    autoFocus: null,
    inputIsValid: isValid
  }
  return (
    <FormGroup isRequired={isRequired}
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
      username: this.props.user.username,
      emailAddress: this.props.user.email,
      firstname: this.props.user.firstname,
      lastname: this.props.user.lastname,
      password: '',
      passwordConfirmation: '',
      isValidUsername: undefined,
      isValidEmailAddress: undefined,
      isValidFirstname: true,
      isValidLastname: true,
      isValidPassword: undefined,
      isValidPasswordConfirmation: undefined
    }
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    const formFields = ['#user_username', '#user_email', '#user_password', '#user_password_confirmation']
    const formValidated = validateFormFields(formFields)

    const newState = {...this.state, ...formValidated.elementsValidity}
    this.setState({ ...newState })

    if (!formValidated.isValid) {
      event.preventDefault()
    }
  }

  handleTextInputUsername = (username: string) =>
    this.setState({ username })

  handleTextInputEmail = (emailAddress: string) =>
    this.setState({ emailAddress })

  handleTextInputFirstname = (firstname: string) => this.setState({ firstname })

  handleTextInputLastname = (lastname: string) => this.setState({ lastname })

  handleTextInputPassword = (password: string) =>
    this.setState({ password })

  handleTextInputPasswordConfirmation = (passwordConfirmation: string) =>
    this.setState({ passwordConfirmation })

  render () {
    const { username, isValidUsername, emailAddress, isValidEmailAddress, firstname, isValidFirstname, lastname, isValidLastname, password, isValidPassword, passwordConfirmation, isValidPasswordConfirmation } = this.state
    return (
      <Form noValidate
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        <InputFormGroup isRequired type='user[username]' value={username} isValid={isValidUsername} onChange={this.handleTextInputUsername} />
        <InputFormGroup isRequired type='user[email]' value={emailAddress} isValid={isValidEmailAddress} onChange={this.handleTextInputEmail} />
        <InputFormGroup isRequired={false} type='user[first_name]' value={firstname} isValid={isValidFirstname} onChange={this.handleTextInputFirstname} />
        <InputFormGroup isRequired={false} type='user[last_name]' value={lastname} isValid={isValidLastname} onChange={this.handleTextInputLastname} />
        <InputFormGroup isRequired type='user[password]' value={password} isValid={isValidPassword} onChange={this.handleTextInputPassword} />
        <InputFormGroup isRequired type='user[password_confirmation]' value={passwordConfirmation} isValid={isValidPasswordConfirmation} onChange={this.handleTextInputPasswordConfirmation} />
        <ActionGroup>
          <input type="submit"
            name="commit"
            value="Sign up"
            className="pf-m-primary pf-c-button pf-m-primary pf-m-block"
            onClick={this.validateForm}
          />
        </ActionGroup>
      </Form>
    )
  }
}

export {
  SignupForm
}
