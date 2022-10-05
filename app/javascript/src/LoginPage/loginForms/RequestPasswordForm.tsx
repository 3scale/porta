import React from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'
import { EmailField } from 'LoginPage/loginForms/FormGroups'
import { HiddenInputs } from 'LoginPage/loginForms/HiddenInputs'
import { validateSingleField } from 'LoginPage/utils/formValidation'

type Props = {
  providerLoginPath: string,
  providerPasswordPath: string
}

type State = {
  email: string,
  validation: {
    email?: boolean
  }
}

// TODO: resolve this react/require-optimization
// eslint-disable-next-line react/require-optimization
class RequestPasswordForm extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = {
      email: '',
      validation: {
        email: undefined
      }
    }
  }

  handleTextInputEmail: (text: string, event: React.SyntheticEvent<HTMLInputElement>) => void = (email, event) => {
    const isValid = validateSingleField(event)
    this.setState({ email, validation: { email: isValid } })
  }

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
        acceptCharset="UTF-8"
        action={this.props.providerPasswordPath}
        id="request_password"
        method="post"
      >
        <HiddenInputs isPasswordReset />
        <EmailField inputProps={emailInputProps} />
        <ActionGroup>
          <Button
            className="pf-c-button pf-m-primary pf-m-block"
            isDisabled={formDisabled}
            type="submit"
          >
            Reset password
          </Button>
          <a href={this.props.providerLoginPath}>Sign in</a>
        </ActionGroup>
      </Form>
    )
  }
}

export { RequestPasswordForm, Props }
