// @flow

import React from 'react'
import type { Node } from 'react'

import {HiddenInputs, FormGroup} from 'LoginPage'

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
      <Form
        action={this.props.providerSessionsPath}
        id='new_session'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs/>
        <FormGroup type='username' labelIsValid={isValidUsername} inputProps={usernameInputProps} />
        <FormGroup type='password' labelIsValid={isValidPassword} inputProps={passwordInputProps} />
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
