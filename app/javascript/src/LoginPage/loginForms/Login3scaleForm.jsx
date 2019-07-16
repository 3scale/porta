// @flow

import React from 'react'
import type { Node } from 'react'

import {HiddenInputs, FormGroup} from 'LoginPage'
import validate from 'validate.js'

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

const constraints = {
  username: {
    presence: true
  },
  password: {
    presence: true
  }
}
const namesToStateKeys = {
  'username': 'isValidUsername',
  'password': 'isValidPassword'
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
    const usernameError = validate.single(username, {presence: true, length: {minimum: 1}})
    const isValidUsername = !usernameError
    this.setState({ username, isValidUsername })
  }

  handleTextInputPassword = (password: string) => {
    const passwordError = validate.single(password, {presence: true, length: {minimum: 1}})
    const isValidPassword = !passwordError
    this.setState({ password, isValidPassword })
  }

  validateForm = (event: SyntheticEvent<HTMLInputElement>) => {
    const errors = validate(event.currentTarget.form, constraints)
    if (errors) {
      event.preventDefault()
      //$FlowFixMe: Needed due to a flow issue with Object values/keys: https://github.com/facebook/flow/issues/2221
      for (const errorId in errors) {
        this.setState({[namesToStateKeys[errorId]]: false})
      }
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
