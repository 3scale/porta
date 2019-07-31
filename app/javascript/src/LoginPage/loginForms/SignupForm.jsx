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

const formFieldsList = [
  {isRequired: true, type: 'user[username]'},
  {isRequired: true, type: 'user[email]'},
  {isRequired: false, type: 'user[first_name]'},
  {isRequired: false, type: 'user[last_name]'},
  {isRequired: true, type: 'user[password]'},
  {isRequired: true, type: 'user[password_confirmation]'}
]

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

  renderInputFormGroups = (formFieldsList: Array<*>): Array<*> => {
    return formFieldsList.map(formField => {
      const inputProps = {
        value: this.state[formField.type],
        onChange: this.handleInputChange,
        inputIsValid: this.state.validation[formField.type]
      }
      return (<FormGroup key={formField.type}
        isRequired={formField.isRequired}
        type={formField.type}
        labelIsValid={this.state.validation[formField.type]}
        inputProps={inputProps}
      />)
    })
  }

  render () {
    return (
      <Form noValidate
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        { this.renderInputFormGroups(formFieldsList) }
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
