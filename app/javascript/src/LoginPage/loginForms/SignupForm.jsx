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
import validate from 'validate.js'

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

const constraints = {
  'user[username]': {
    presence: true
  },
  'user[email]': {
    presence: true,
    email: true
  },
  'user[password]': {
    presence: true
  },
  'user[password_confirmation]': {
    presence: true,
    equality: {
      attribute: 'user[password]'
    }
  }
}
const namesToStateKeys = {
  'user[username]': 'isValidUsername',
  'user[email]': 'isValidEmailAddress',
  'user[password]': 'isValidPassword',
  'user[password_confirmation]': 'isValidPasswordConfirmation'
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

  handleTextInputUsername = (username: string) => {
    const usernameError = validate.single(username, {presence: true, length: {minimum: 1}})
    const isValidUsername = !usernameError
    this.setState({ username, isValidUsername })
  }

  handleTextInputEmail = (emailAddress: string) => {
    const emailError = validate.single(emailAddress, {presence: true, email: true})
    const isValidEmailAddress = !emailError
    this.setState({ emailAddress, isValidEmailAddress })
  }

  handleTextInputFirstname = (firstname: string) => this.setState({ firstname })

  handleTextInputLastname = (lastname: string) => this.setState({ lastname })

  handleTextInputPassword = (password: string) => {
    const passwordError = validate.single(password, {presence: true, length: {minimum: 1}})
    const isValidPassword = !passwordError
    this.setState({password, isValidPassword})
  }

  handleTextInputPasswordConfirmation = (passwordConfirmation: string) => {
    const passwordConfirmationError = validate.single(passwordConfirmation, {presence: true, length: {minimum: 1}})
    const isValidPasswordConfirmation = !passwordConfirmationError
    this.setState({passwordConfirmation, isValidPasswordConfirmation})
  }

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    const errors = validate(event.currentTarget.form, constraints)
    if (errors) {
      event.preventDefault()
      //$FlowFixMe: Needed due to a flow issue with Object values/keys: https://github.com/facebook/flow/issues/2221
      for (const errorId in errors) {
        this.setState({ [namesToStateKeys[errorId]]: false })
      }
    }
  }

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
