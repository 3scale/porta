// @flow

import React from 'react'
import type { Node } from 'react'

import {HiddenInputs, FormGroup} from 'LoginPage'
import validate from 'validate.js'

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

const constraints = {
  email: {
    presence: true,
    email: true
  }
}
const namesToStateKeys = {
  'email': 'isValidEmail'
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
    const emailError = validate.single(emailAddress, {presence: true, email: true})
    const isValidEmail = !emailError
    this.setState({ emailAddress, isValidEmail })
  }

  validateForm = (event: SyntheticEvent<HTMLButtonElement>) => {
    const errors = validate(event.currentTarget.form, constraints)
    if (errors) {
      event.preventDefault()
      //$FlowFixMe: Needed due to a flow issue with Object values/keys: https://github.com/facebook/flow/issues/2221
      for (const errorId in Object.keys(errors)) {
        this.setState({[namesToStateKeys[errorId]]: false})
      }  
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
      <Form action={this.props.providerPasswordPath}
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset/>
        <FormGroup type='email' labelIsValid={isValidEmail} inputProps={emailInputProps} />
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
