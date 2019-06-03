import React from 'react'

import {HiddenInputs} from 'LoginPage'

import {
  Form,
  FormGroup,
  TextInput,
  ActionGroup,
  Button
} from '@patternfly/react-core'

class RequestPasswordForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      emailAddress: ''
    }
    this.handleTextInputEmail = emailAddress => {
      this.setState({ emailAddress })
    }
  }

  render () {
    const {emailAddress} = this.state
    return (
      <Form
        noValidate={false}
        action={this.props.providerPasswordPath}
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs isPasswordReset/>
        <FormGroup label='Email address' isRequired fieldId='email'>
          <TextInput
            isRequired
            type='email'
            id='email'
            name='email'
            value={emailAddress}
            onChange={this.handleTextInputEmail}
            autoFocus='autoFocus'
          />
        </FormGroup>
        <ActionGroup>
          <Button
            className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
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
