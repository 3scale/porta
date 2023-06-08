import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'

import { EmailField } from 'Login/components/FormGroups'
import { HiddenInputs } from 'Login/components/HiddenInputs'
import { validateSingleField } from 'Login/utils/formValidation'

import type { FunctionComponent } from 'react'

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

const RequestPasswordForm: FunctionComponent<Props> = (props) => {
  const [state, setState] = useState<State>({
    email: '',
    validation: {
      email: undefined
    }
  })

  const handleTextInputEmail: (text: string, event: React.SyntheticEvent<HTMLInputElement>) => void = (email, event) => {
    const isValid = validateSingleField(event)
    setState({ email, validation: { email: isValid } })
  }

  const emailInputProps = {
    isRequired: true,
    name: 'email',
    fieldId: 'email',
    label: 'Email address',
    isValid: state.validation.email,
    value: state.email,
    onChange: handleTextInputEmail,
    autoFocus: true
  } as const
  const formDisabled = Object.values(state.validation).some(value => !value)
  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={props.providerPasswordPath}
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
        <a href={props.providerLoginPath}>Sign in</a>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { RequestPasswordForm }
