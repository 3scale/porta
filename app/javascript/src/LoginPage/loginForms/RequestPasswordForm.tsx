import React from 'react'
import type { ReactNode } from 'react'

import {
  HiddenInputs,
  EmailField,
  validateSingleField
} from 'LoginPage'

import {
  Form,
  ActionGroup,
  Button
} from '@patternfly/react-core'

export type Props = {
  providerLoginPath: string,
  providerPasswordPath: string
};

type State = {
  email: string,
  validation: {
    email?: boolean
  }
};

class RequestPasswordForm extends React.Component<Props, State> {
  state: State = {
    email: '',
    validation: {
      email: undefined
    }
  };

  handleTextInputEmail: (arg1: string, arg2: React.SyntheticEvent<HTMLInputElement>) => void = (email, event) => {
    const isValid = validateSingleField(event)
    this.setState({ email, validation: { email: isValid } })
  };

  render () {
    const emailInputProps = {
      isRequired: true,
      name: 'email',
      fieldId: 'email',
      label: 'Email address',
      isValid: this.state.validation.email,
      value: this.state.email,
      onChange: this.handleTextInputEmail,
      autoFocus: true
    } as const
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)
    return (
      <Form
        noValidate
        action={this.props.providerPasswordPath}
        id='request_password'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset />
        <EmailField inputProps={emailInputProps}/>
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
