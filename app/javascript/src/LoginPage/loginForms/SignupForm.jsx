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
  validateSingleField
} from 'LoginPage'
import type {SignupProps} from 'Types'

const INPUT_NAMES = {
  username: 'user[username]',
  email: 'user[email]',
  firstName: 'user[first_name]',
  lastName: 'user[last_name]',
  password: 'user[password]',
  passwordConfirmation: 'user[password_confirmation]'
}

const formFieldsList = [
  {isRequired: true, type: INPUT_NAMES.username},
  {isRequired: true, type: INPUT_NAMES.email},
  {isRequired: false, type: INPUT_NAMES.firstName},
  {isRequired: false, type: INPUT_NAMES.lastName},
  {isRequired: true, type: INPUT_NAMES.password},
  {isRequired: true, type: INPUT_NAMES.passwordConfirmation}
]

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
  'validation': Validation
}

class SignupForm extends Component<SignupProps, State> {
  state = {
    [INPUT_NAMES.username]: this.props.user.username,
    [INPUT_NAMES.email]: this.props.user.email,
    [INPUT_NAMES.firstName]: this.props.user.firstname,
    [INPUT_NAMES.lastName]: this.props.user.lastname,
    [INPUT_NAMES.password]: '',
    [INPUT_NAMES.passwordConfirmation]: '',
    validation: {
      [INPUT_NAMES.username]: this.props.user.username ? true : undefined,
      [INPUT_NAMES.email]: this.props.user.email ? true : undefined,
      [INPUT_NAMES.firstName]: true,
      [INPUT_NAMES.lastName]: true,
      [INPUT_NAMES.password]: undefined,
      [INPUT_NAMES.passwordConfirmation]: undefined
    }
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
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)
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
            isDisabled={formDisabled}
          >Sign up</Button>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  SignupForm
}
