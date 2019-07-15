// @flow

import React from 'react'
import type { Node } from 'react'

import {HiddenInputs, FormGroup} from 'LoginPage'
import Pristine from 'pristinejs'

import {
  Form,
  ActionGroup,
  Button
} from '@patternfly/react-core'

const idsToStateKeys = {
  'email': 'isValidEmail'
}

type Props = {
  providerLoginPath: string,
  providerPasswordPath: string
}

type State = {
  emailAddress: string,
  isValidEmail: ?boolean
}

type Error = {
  input: {
    id: string
  },
  errors: string[]
}

class RequestPasswordForm extends React.Component<Props, State> {
  pristine: any

  state = {
    emailAddress: '',
    isValidEmail: undefined
  }

  componentDidMount () {
    const formElement = document.getElementById('request_password_form')
    this.pristine = new Pristine(formElement)
  }

  handleTextInputEmail = (emailAddress: string, event: SyntheticEvent<HTMLInputElement>) => {
    this.setState({ emailAddress })
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
    this.setState({ isValidEmail: isFieldValid }) 
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    const valid = this.pristine.validate()
    const errors = this.pristine.getErrors()
    if (!valid) {
      event.preventDefault()
      this.setInvalidFields(errors)
    }
  }

  render (): Node {
    const {emailAddress, isValidEmail} = this.state
    const emailInputProps = {
      value: emailAddress,
      onChange: this.handleTextInputEmail,
      autoFocus: 'autoFocus',
      inputIsValid: isValidEmail
    }
    return (
      <Form action={this.props.providerPasswordPath}
        id='request_password_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset/>
        <FormGroup isRequired type='email' labelIsValid={isValidEmail} inputProps={emailInputProps} />
        <ActionGroup>
          <Button
            className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            onClick={this.validateForm}
          >Reset password</Button>
          <a href={this.props.providerLoginPath}>Sign in</a>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  RequestPasswordForm
}
