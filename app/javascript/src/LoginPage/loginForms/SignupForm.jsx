// @flow

import React, { Component } from 'react'
import {
  Form,
  ActionGroup
} from '@patternfly/react-core'
import {
  HiddenInputs,
  FormGroup,
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
  email: string,
  firstName: string,
  lastName: string,
  password: string,
  passwordConfirmation: string,
  validation: {
    username: ?boolean,
    email: ?boolean,
    firstName: boolean,
    lastName: boolean,
    password: ?boolean,
    passwordConfirmation: ?boolean
  }
}

type NamesToKeys = {
  [string]: string
}

type InvalidFields = {
  [string]: boolean
}

const namesToStateKeys = {
  'user[username]': 'username',
  'user[email]': 'email',
  'user[first_name]': 'firstName',
  'user[last_name]': 'lastName',
  'user[password]': 'password',
  'user[password_confirmation]': 'passwordConfirmation'
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
  state = {
    username: this.props.user.username,
    email: this.props.user.email,
    firstName: this.props.user.firstname,
    lastName: this.props.user.lastname,
    password: '',
    passwordConfirmation: '',
    validation: {
      username: undefined,
      email: undefined,
      firstName: true,
      lastName: true,
      password: undefined,
      passwordConfirmation: undefined
    }
  }

  handleInputChange = (value: string, event: SyntheticEvent<HTMLInputElement>) => {
    const isValid = validateSingleField(event)
    const validation = {
      ...this.state.validation,
      [namesToStateKeys[event.currentTarget.name]]: isValid
    }

    this.setState({
      [namesToStateKeys[event.currentTarget.name]]: value,
      validation
    })
  }

  renameValidation = (namesToStateKeys: NamesToKeys, invalidFields: InvalidFields) => Object.keys(invalidFields)
    .reduce((obj, item) => {
      obj[namesToStateKeys[item]] = invalidFields[item]
      return obj
    }, {})

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    const invalidFields = validateAllFields(event.currentTarget.form)

    if (invalidFields) {
      event.preventDefault()
      const validation = this.renameValidation(namesToStateKeys, invalidFields)
      this.setState({validation})
    }
  }

  render () {
    const {username, email, firstName, lastName, password, passwordConfirmation, validation} = this.state

    return (
      <Form noValidate
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        <InputFormGroup isRequired type='user[username]' value={username} isValid={validation.username} onChange={this.handleInputChange} />
        <InputFormGroup isRequired type='user[email]' value={email} isValid={validation.email} onChange={this.handleInputChange} />
        <InputFormGroup isRequired={false} type='user[first_name]' value={firstName} isValid={validation.firstName} onChange={this.handleInputChange} />
        <InputFormGroup isRequired={false} type='user[last_name]' value={lastName} isValid={validation.lastName} onChange={this.handleInputChange} />
        <InputFormGroup isRequired type='user[password]' value={password} isValid={validation.password} onChange={this.handleInputChange} />
        <InputFormGroup isRequired type='user[password_confirmation]' value={passwordConfirmation} isValid={validation.passwordConfirmation} onChange={this.handleInputChange} />
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
