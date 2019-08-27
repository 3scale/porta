// @flow

import React, { Component } from 'react'
import {
  Form,
  ActionGroup,
  Button
} from '@patternfly/react-core'
import {
  HiddenInputs,
  FormGroup,
  validateSingleField,
  isFormDisabled
} from 'LoginPage'

type User = {
    email: string,
    username: string,
    firstname: string,
    lastname: string
}

type Props = {
  path: string,
  user: User
}

type Validation = {
  [string]: ?boolean
}

type State = {
  'formDisabled': boolean,
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
    'formDisabled': true,
    'user[username]': this.props.user.username,
    'user[email]': this.props.user.email,
    'user[first_name]': this.props.user.firstname,
    'user[last_name]': this.props.user.lastname,
    'user[password]': '',
    'user[password_confirmation]': '',
    validation: {
      'user[username]': undefined,
      'user[email]': undefined,
      'user[first_name]': true,
      'user[last_name]': true,
      'user[password]': undefined,
      'user[password_confirmation]': undefined
    }
  }

  validateUserPrefilledValues = () => {
    const prefilledInputsIDs = ['#user_username', '#user_email', '#user_first_name', '#user_last_name']

    prefilledInputsIDs.forEach(id => {
      const input = document.querySelector(id)
      if (input instanceof HTMLInputElement && input.value) {
        const validation = {
          ...this.state.validation,
          [input.name]: true
        }
        this.setState({validation})
      }
    })
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
    }, this.validateForm)
  }

  validateForm = () => this.setState({
    formDisabled: isFormDisabled(Object.values(this.state.validation))
  })

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

  componentDidMount () {
    this.validateUserPrefilledValues()
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
          <Button className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            name="commit"
            isDisabled={this.state.formDisabled}
            onClick={this.validateForm}
          >Sign up</Button>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  SignupForm
}
