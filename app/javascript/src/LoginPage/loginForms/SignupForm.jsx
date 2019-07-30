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

type Validation = {
  [string]: ?boolean
}

type State = {
  'user[username]': string,
  'user[email]': string,
  'user[first_name]': string,
  'user[last_name]': string,
  'user[password]': string,
  'user[password_confirmation]': string,
  validation: Validation
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
    'user[username]': this.props.user.username,
    'user[email]': this.props.user.email,
    'user[first_name]': this.props.user.firstname,
    'user[last_name]': this.props.user.lastname,
    'user[password]': '',
    'user[password_confirmation]': '',
    validation: {}
  }

  handleInputChange = (value: string, event: SyntheticEvent<HTMLInputElement>) => {
    const isValid = event.currentTarget.required ? validateSingleField(event) : true
    const validation = {
      ...this.state.validation,
      [event.currentTarget.name]: isValid
    }

    this.setState({
      [event.currentTarget.name]: value,
      validation
    })
  }

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    const invalidFields = validateAllFields(event.currentTarget.form)

    if (invalidFields) {
      event.preventDefault()
      this.setState({validation: invalidFields})
    }
  }

  render () {
    const {validation} = this.state

    return (
      <Form noValidate
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        <InputFormGroup isRequired
          type='user[username]'
          value={this.state['user[username]']}
          isValid={validation['user[username]']}
          onChange={this.handleInputChange} />
        <InputFormGroup isRequired
          type='user[email]'
          value={this.state['user[email]']}
          isValid={validation['user[email]']}
          onChange={this.handleInputChange} />
        <InputFormGroup isRequired={false}
          type='user[first_name]'
          value={this.state['user[first_name]']}
          isValid={validation['user[first_name]']}
          onChange={this.handleInputChange} />
        <InputFormGroup isRequired={false}
          type='user[last_name]'
          value={this.state['user[last_name]']}
          isValid={validation['user[last_name]']}
          onChange={this.handleInputChange} />
        <InputFormGroup isRequired
          type='user[password]'
          value={this.state['user[password]']}
          isValid={validation['user[password]']}
          onChange={this.handleInputChange} />
        <InputFormGroup isRequired
          type='user[password_confirmation]'
          value={this.state['user[password_confirmation]']}
          isValid={validation['user[password_confirmation]']}
          onChange={this.handleInputChange} />
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
