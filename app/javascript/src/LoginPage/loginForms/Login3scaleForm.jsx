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
  'session_username': 'isValidUsername',
  'session_password': 'isValidPassword'
}

type Props = {
  providerSessionsPath: string
}

type State = {
  username: string,
  password: string,
  isValidUsername: ?boolean,
  isValidPassword: ?boolean
}

type Error = {
  input: {
    id: string
  },
  errors: string[]
}

class Login3scaleForm extends React.Component<Props, State> {
  pristine: any

  state = {
    username: '',
    password: '',
    isValidUsername: undefined,
    isValidPassword: undefined
  }

  componentDidMount () {
    const formElement = document.getElementById('new_session')
    this.pristine = new Pristine(formElement)
  }

  handleTextInputUsername = (username: string, event: SyntheticEvent<HTMLInputElement>) => {
    this.setState({username})
    this.validateFormfield(event.currentTarget.id)
  }

  handleTextInputPassword = (password: string, event: SyntheticEvent<HTMLInputElement>) => {
    this.setState({password})
    this.validateFormfield(event.currentTarget.id)
  }

  setInvalidFields = (errors: Array<Error>) => {
    for (const error of errors) {
      (error) => this.setState({[idsToStateKeys[error.input.id]]: false})
    }
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

  render (): Node {
    const {username, password, isValidUsername, isValidPassword} = this.state
    const usernameInputProps = {
      value: username,
      onChange: this.handleTextInputUsername,
      autoFocus: 'autoFocus',
      inputIsValid: isValidUsername
    }
    const passwordInputProps = {
      value: password,
      onChange: this.handleTextInputPassword,
      ariaInvalid: 'false',
      inputIsValid: isValidPassword
    }
    return (
      <Form noValidate={true}
        action={this.props.providerSessionsPath}
        id='new_session'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs/>
        <FormGroup isRequired type='username' labelIsValid={isValidUsername} inputProps={usernameInputProps} />
        <FormGroup isRequired type='password' labelIsValid={isValidPassword} inputProps={passwordInputProps} />
        <ActionGroup>
          <Button
            className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            onClick={this.validateForm}
          > Sign in</Button>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  Login3scaleForm
}
