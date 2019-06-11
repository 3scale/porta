// @flow

import React from 'react'
import type { Node } from 'react'

import {HiddenInputs} from 'LoginPage'

import {
  Form,
  FormGroup,
  TextInput,
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
    this.handleTextInputUsername = this.handleTextInputUsername.bind(this)
    this.handleTextInputPassword = this.handleTextInputPassword.bind(this)
    this.validateForm = this.validateForm.bind(this)
  }

  setIsValidUsername = () => {
    this.setState({isValidUsername: this.state.username !== ''})
  }

  handleTextInputUsername = (username: string) => {
    this.setState({ username }, this.setIsValidUsername)
  }

  setIsValidPassword = () => {
    this.setState({isValidPassword: this.state.password !== ''})
  }

  handleTextInputPassword = (password: string) => {
    this.setState({ password }, this.setIsValidPassword)
  }

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    this.setIsValidUsername()
    this.setIsValidPassword()
    const isFormDisabled = this.state.username === '' ||
      this.state.password === '' ||
      this.state.isValidUsername === false ||
      this.state.isValidPassword === false
    if (isFormDisabled) {
      event.preventDefault()
    }
  }

  render (): Node {
    const {username, password, isValidUsername, isValidPassword} = this.state
    return (
      <Form
        action={this.props.providerSessionsPath}
        id='new_session'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs/>
        <FormGroup
          label='Email or Username'
          isRequired
          fieldId='session_username'
          helperTextInvalid='Email or username is mandatory'
          isValid={isValidUsername}
        >
          <TextInput
            isRequired
            type='text'
            id='session_username'
            name='username'
            tabIndex='1'
            value={username}
            onChange={this.handleTextInputUsername}
            autoFocus='autoFocus'
            isValid={isValidUsername}
          />
        </FormGroup>
        <FormGroup
          label='Password'
          isRequired
          fieldId='session_password'
          helperTextInvalid='Password is mandatory'
          isValid={isValidPassword}
        >
          <TextInput
            isRequired
            type='password'
            id='session_password'
            name='password'
            tabIndex='2'
            value={password}
            onChange={this.handleTextInputPassword}
            aria-invalid='false'
            isValid={isValidPassword}
          />
        </FormGroup>
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
