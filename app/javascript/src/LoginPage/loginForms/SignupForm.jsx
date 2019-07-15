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
import Pristine from 'pristinejs'

const idsToStateKeys = {
  'user_username': 'isValidUsername',
  'user_email': 'isValidEmailAddress',
  'user_password': 'isValidPassword',
  'user_password_confirmation': 'isValidPasswordConfirmation'
}

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

type Error = {
  input: {
    id: string
  },
  errors: string[]
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
  pristine: any

  state = {
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

  componentDidMount () {
    const formElement = document.getElementById('signup_form')
    this.pristine = new Pristine(formElement)
  }

  handleTextInputUsername = (username: string, event: SyntheticEvent<HTMLInputElement>) => {
    this.setState({ username })
    this.validateFormfield(event.currentTarget.id)
  }

  handleTextInputEmail = (emailAddress: string, event: SyntheticEvent<HTMLInputElement>) => {
    this.setState({ emailAddress })
    this.validateFormfield(event.currentTarget.id)
  }

  handleTextInputFirstname = (firstname: string) => {
    this.setState({ firstname })
  }

  handleTextInputLastname = (lastname: string) => this.setState({ lastname })

  handleTextInputPassword = (password: string, event: SyntheticEvent<HTMLInputElement>) => {
    this.setState({ password })
    this.validateFormfield(event.currentTarget.id)
  }

  handleTextInputPasswordConfirmation = (passwordConfirmation: string, event: SyntheticEvent<HTMLInputElement>) => {
    this.setState({ passwordConfirmation })
    this.validateFormfield(event.currentTarget.id)
  }

  setInvalidFields = (errors: Array<Error>) => {
    errors.forEach(
      (error) => this.setState({[idsToStateKeys[error.input.id]]: false})
    )
  }

  validateFormfield = (id: string) => {
    const field = document.getElementById(id)
    const isFieldValid = this.pristine.validate(field)
    this.setState({[idsToStateKeys[id]]: isFieldValid})
  }

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    const valid = this.pristine.validate()
    const errors = this.pristine.getErrors()
    if (!valid) {
      event.preventDefault()
      this.setInvalidFields(errors)
    }
  }

  render () {
    const { username, isValidUsername, emailAddress, isValidEmailAddress, firstname, isValidFirstname, lastname, isValidLastname, password, isValidPassword, passwordConfirmation, isValidPasswordConfirmation } = this.state
    return (
      <Form noValidate={true}
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
