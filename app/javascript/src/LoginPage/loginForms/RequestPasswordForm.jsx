// @flow

import React from 'react'
import type { Node } from 'react'

import {
  HiddenInputs,
  FormGroup,
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
  email: string,
  validation: {
    email: ?boolean
  }
}

class RequestPasswordForm extends React.Component<Props, State> {
  state = {
    email: '',
    validation: {}
  }

  handleTextInputEmail = (email: string, event: SyntheticEvent<HTMLInputElement>) => {
    const isValid = validateSingleField(event)
    this.setState({ email, validation: {email: isValid} })
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    const invalidFields = validateAllFields(event.currentTarget.form)

    if (invalidFields) {
      event.preventDefault()
      this.setState({validation: invalidFields})
    }
  }

  render (): Node {
    const {email, validation} = this.state
    const emailInputProps = {
      value: email,
      onChange: this.handleTextInputEmail,
      autoFocus: 'autoFocus',
      inputIsValid: validation.email
    }
    return (
      <Form noValidate
        action={this.props.providerPasswordPath}
        id='request_password'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset/>
        <FormGroup type='email' labelIsValid={validation.email} inputProps={emailInputProps} />
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
