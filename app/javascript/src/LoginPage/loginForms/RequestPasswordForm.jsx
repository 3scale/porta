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

  render (): Node {
    const emailInputProps = {
      value: this.state.email,
      onChange: this.handleTextInputEmail,
      autoFocus: 'autoFocus',
      inputIsValid: this.state.validation.email
    }
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)
    return (
      <Form noValidate id='request_password'
        action={this.props.providerPasswordPath}
        id='request_password'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset />
        <FormGroup type='email' labelIsValid={this.state.validation.email} inputProps={emailInputProps} />
        <ActionGroup>
          <Button className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            isDisabled={formDisabled}
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
