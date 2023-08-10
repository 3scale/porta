import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'

import { EmailField } from 'Login/components/FormGroups'
import { HiddenInputs } from 'Login/components/HiddenInputs'
import { validateSingleField } from 'Login/utils/formValidation'

import type { FunctionComponent, FormEvent } from 'react'

interface Props {
  providerLoginPath: string;
  providerPasswordPath: string;
}

const RequestPasswordForm: FunctionComponent<Props> = (props) => {
  const [email, setEmail] = useState('')
  const [validation, setValidation] = useState({
    email: undefined as boolean | undefined
  })

  // TODO: validations should happen on loss focus or sibmission
  const onEmailChange = (value: string, event: FormEvent<HTMLInputElement>) => {
    const { currentTarget } = event
    setEmail(value)
    setValidation(prev => ({ ...prev, email: validateSingleField(currentTarget) }))
  }

  const formDisabled = Object.values(validation).some(value => !value)
  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={props.providerPasswordPath}
      id="request_password"
      method="post"
    >
      <HiddenInputs isPasswordReset />
      <EmailField inputProps={{
        isRequired: true,
        name: 'email',
        fieldId: 'email',
        label: 'Email address',
        isValid: validation.email,
        value: email,
        onChange: onEmailChange,
        autoFocus: true
      }}
      />
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
