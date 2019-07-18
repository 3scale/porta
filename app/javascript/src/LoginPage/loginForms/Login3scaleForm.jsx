// @flow

import React from 'react'
import type { Node } from 'react'

import {
  HiddenInputs,
  FormGroup,
  namesToStateKeys,
  validateAllFields,
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

  handleInputChange = (value: string, event: SyntheticEvent<HTMLInputElement>) => {
    const isValid = validateSingleField(event)
    this.setState({
      [namesToStateKeys[event.currentTarget.name].name]: value,
      [namesToStateKeys[event.currentTarget.name].isValid]: isValid
    })
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    const errors = validateAllFields(event.currentTarget.form)
    if (errors) {
      event.preventDefault()
      errors.forEach(
        (error) => this.setState({[namesToStateKeys[error].isValid]: false})
      )
    }
  }

  render (): Node {
    const {username, password, isValidUsername, isValidPassword} = this.state
    const usernameInputProps = {
      value: username,
      onChange: this.handleInputChange,
      autoFocus: 'autoFocus',
      inputIsValid: isValidUsername
    }
    const passwordInputProps = {
      value: password,
      onChange: this.handleInputChange,
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
