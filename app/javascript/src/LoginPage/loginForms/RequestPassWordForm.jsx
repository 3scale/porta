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
    this.handleTextInputEmail = this.handleTextInputEmail.bind(this)
    this.validateForm = this.validateForm.bind(this)
  }

  setIsValidEmail = () => {
    const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    const isValidEmail = re.test(this.state.emailAddress)
    this.setState({isValidEmail})
  }

  handleTextInputEmail = (emailAddress: string) => {
    this.setState({ emailAddress }, this.setIsValidEmail)
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    this.setIsValidEmail()
    const isFormDisabled = this.state.isValidEmail === false ||
      this.state.emailAddress === ''
    if (isFormDisabled) {
      event.preventDefault()
    }
  }

  render (): Node {
    const {emailAddress, isValidEmail} = this.state
    return (
      <Form
        action={this.props.providerPasswordPath}
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset/>
        <FormGroup
          label='Email address'
          isRequired
          fieldId='email'
          helperTextInvalid='A valid email address is mandatory'
          isValid={isValidEmail}
        >
          <TextInput
            isRequired
            type='email'
            id='email'
            name='email'
            value={emailAddress}
            onChange={this.handleTextInputEmail}
            autoFocus='autoFocus'
            isValid={isValidEmail}
          />
        </FormGroup>
        <ActionGroup>
          <Button
            className='pf-c-button pf-m-primary pf-m-block'
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
