// @flow

import React, { Component } from 'react'
import {
  Form,
  ActionGroup
} from '@patternfly/react-core'
import {
  HiddenInputs,
  FormGroup,
  namesToStateKeys,
  validateAllFields,
  validateSingleField
} from 'LoginPage'

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

  handleInputChange = (value: string, event: SyntheticEvent<HTMLInputElement>) => {
    const isValid = validateSingleField(event)
    this.setState({
      [namesToStateKeys[event.currentTarget.name].name]: value,
      [namesToStateKeys[event.currentTarget.name].isValid]: isValid
    })
  }

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    const errors = validateAllFields(event.currentTarget.form)
    if (errors) {
      event.preventDefault()
      errors.forEach(
        (error) => this.setState({[namesToStateKeys[error].isValid]: false})
      )
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
        <InputFormGroup isRequired type='user[username]' value={username} isValid={isValidUsername} onChange={this.handleInputChange} />
        <InputFormGroup isRequired type='user[email]' value={emailAddress} isValid={isValidEmailAddress} onChange={this.handleInputChange} />
        <InputFormGroup isRequired={false} type='user[first_name]' value={firstname} isValid={isValidFirstname} onChange={this.handleInputChange} />
        <InputFormGroup isRequired={false} type='user[last_name]' value={lastname} isValid={isValidLastname} onChange={this.handleInputChange} />
        <InputFormGroup isRequired type='user[password]' value={password} isValid={isValidPassword} onChange={this.handleInputChange} />
        <InputFormGroup isRequired type='user[password_confirmation]' value={passwordConfirmation} isValid={isValidPasswordConfirmation} onChange={this.handleInputChange} />
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
