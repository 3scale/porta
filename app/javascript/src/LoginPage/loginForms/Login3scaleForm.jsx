import React from 'react'

import {HiddenInputs} from 'LoginPage'

import {
  Form,
  FormGroup,
  TextInput,
  ActionGroup,
  Button
} from '@patternfly/react-core'

class Login3scaleForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      username: '',
      password: ''
    }
    this.handleTextInputUsername = username => {
      this.setState({ username })
    }
    this.handleTextInputPassword = password => {
      this.setState({ password })
    }
  }

  render () {
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
