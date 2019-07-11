// @flow

import React from 'react'
import type { Node } from 'react'

import {HiddenInputs, FormGroup} from 'LoginPage'
import { validateFormFields } from 'utilities/formValidation'

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

  handleTextInputEmail = (emailAddress: string) => {
    this.setState({ emailAddress })
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    const formFields = ['#email']
    const formValidated = validateFormFields(formFields)

    const newState = {...this.state, ...formValidated.elementsValidity}
    this.setState({ ...newState })

    if (!formValidated.isValid) {
      event.preventDefault()
    }
  }

  render (): Node {
    const { emailAddress, isValidEmail } = this.state
    const emailInputProps = {
      value: emailAddress,
      onChange: this.handleTextInputEmail,
      autoFocus: 'autoFocus',
      inputIsValid: isValidEmail
    }
    return (
      <Form noValidate
        action={this.props.providerPasswordPath}
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset />
        <FormGroup isRequired type='email' labelIsValid={isValidEmail} inputProps={emailInputProps} />
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
