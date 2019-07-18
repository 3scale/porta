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
  providerLoginPath: string,
  providerPasswordPath: string
}

type State = {
  emailAddress: string,
  isValidEmail: ?boolean
}

class RequestPasswordForm extends React.Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      emailAddress: '',
      isValidEmail: undefined
    }
  }

  handleTextInputEmail = (emailAddress: string, event: SyntheticEvent<HTMLInputElement>) => {
    const isValidEmail = validateSingleField(event)
    this.setState({ emailAddress, isValidEmail })
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
    const {emailAddress, isValidEmail} = this.state
    const emailInputProps = {
      value: emailAddress,
      onChange: this.handleTextInputEmail,
      autoFocus: 'autoFocus',
      inputIsValid: isValidEmail
    }
    return (
      <Form noValidate
        action={this.props.providerPasswordPath}
        id='request_password'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset/>
        <FormGroup type='email' labelIsValid={isValidEmail} inputProps={emailInputProps} />
        <ActionGroup>
          <Button className='pf-c-button pf-m-primary pf-m-block'
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
