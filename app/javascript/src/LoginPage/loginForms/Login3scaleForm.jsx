// @flow

import React from 'react'
import type { Node } from 'react'

import {
  HiddenInputs,
  FormGroup,
  validateSingleField
} from 'LoginPage'

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
  validation: {
    username: ?boolean,
    password: ?boolean
  }
}

class Login3scaleForm extends React.Component<Props, State> {
  state = {
    username: '',
    password: '',
    validation: {
      username: undefined,
      password: undefined
    }
  }

  handleInputChange = (value: string, event: SyntheticEvent<HTMLInputElement>) => {
    const isValid = validateSingleField(event)
    const validation = {
      ...this.state.validation,
      [event.currentTarget.name]: isValid
    }
    this.setState({
      [event.currentTarget.name]: value,
      validation
    })
  }

  render (): Node {
    const {username, password, validation} = this.state
    const usernameInputProps = {
      value: username,
      onChange: this.handleInputChange,
      autoFocus: 'autoFocus',
      inputIsValid: validation.username
    }
    const passwordInputProps = {
      value: password,
      onChange: this.handleInputChange,
      ariaInvalid: 'false',
      inputIsValid: validation.password
    }
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)
    return (
      <Form noValidate
        action={this.props.providerSessionsPath}
        id='new_session'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs/>
        <FormGroup type='username' labelIsValid={validation.username} inputProps={usernameInputProps} />
        <FormGroup type='password' labelIsValid={validation.password} inputProps={passwordInputProps} />
        <ActionGroup>
          <Button className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            isDisabled={formDisabled}
          > Sign in</Button>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  Login3scaleForm
}
