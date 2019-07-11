// @flow

import React from 'react'
import type { Node } from 'react'

import {HiddenInputs, FormGroup} from 'LoginPage'
import { validateFormFields } from 'utilities/formValidation'

import {
  Form,
  ActionGroup,
  Button
} from '@patternfly/react-core'

type Props = {
  providerSessionsPath: string
}

type State = {
  username: string,
  password: string,
  isValidUsername: ?boolean,
  isValidPassword: ?boolean
}

class Login3scaleForm extends React.Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      username: '',
      password: '',
      isValidUsername: undefined,
      isValidPassword: undefined
    }
  }

  handleTextInputUsername = (username: string) => {
    this.setState({ username })
  }

  handleTextInputPassword = (password: string) => {
    this.setState({ password })
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    const formFields = ['#session_username', '#session_password']
    const formValidated = validateFormFields(formFields)

    const newState = {...this.state, ...formValidated.elementsValidity}
    this.setState({ ...newState })

    if (!formValidated.isValid) {
      event.preventDefault()
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
      <Form noValidate
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
