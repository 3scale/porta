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
  password: string
}

class Login3scaleForm extends React.Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      username: '',
      password: ''
    }
    this.handleTextInputUsername = this.handleTextInputUsername.bind(this)
    this.handleTextInputPassword = this.handleTextInputPassword.bind(this)
  }

  handleTextInputUsername = (username: string) => {
    this.setState({ username })
  }
  handleTextInputPassword = (password: string) => {
    this.setState({ password })
  }

  render (): Node {
    const {username, password} = this.state
    return (
      <Form
        noValidate={false}
        action={this.props.providerSessionsPath}
        id='new_session'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs/>
        <FormGroup label='Email or Username' isRequired fieldId='session_username'>
          <TextInput
            isRequired
            type='text'
            id='session_username'
            name='username'
            tabIndex='1'
            value={username}
            onChange={this.handleTextInputUsername}
            autoFocus='autoFocus'
          />
        </FormGroup>
        <FormGroup label='Password' isRequired fieldId='session_password'>
          <TextInput
            isRequired
            type='password'
            id='session_password'
            name='password'
            tabIndex='2'
            value={password}
            onChange={this.handleTextInputPassword}
            aria-invalid='false'
          />
        </FormGroup>
        <ActionGroup>
          <Button
            className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
          > Sign in</Button>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  Login3scaleForm
}
