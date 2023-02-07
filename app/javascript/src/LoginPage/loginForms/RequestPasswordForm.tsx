import { Component } from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'

import { EmailField } from 'LoginPage/loginForms/FormGroups'
import { HiddenInputs } from 'LoginPage/loginForms/HiddenInputs'
import { validateSingleField } from 'LoginPage/utils/formValidation'

import type { ReactNode } from 'react'

interface Props {
  providerLoginPath: string;
  providerPasswordPath: string;
}

interface State {
  email: string;
  validation: {
    email?: boolean;
  };
}

// eslint-disable-next-line react/require-optimization -- TODO: resolve this react/require-optimization
class RequestPasswordForm extends Component<Props, State> {
  public constructor (props: Props) {
    super(props)
    this.state = {
      email: '',
      validation: {
        email: undefined
      }
    }
  }

  private readonly handleTextInputEmail: (text: string, event: React.SyntheticEvent<HTMLInputElement>) => void = (email, event) => {
    const isValid = validateSingleField(event)
    this.setState({ email, validation: { email: isValid } })
  }

  // eslint-disable-next-line @typescript-eslint/member-ordering
  public render (): ReactNode {
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
    const formDisabled = Object.values(this.state.validation).some(value => !value)
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
