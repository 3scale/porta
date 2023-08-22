import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  TextInput
} from '@patternfly/react-core'

import { validateRequestPassword } from 'Login/utils/validations'
import { CSRFToken } from 'utilities/CSRFToken'
import { LoginAlert } from 'Login/components/FormAlert'

import type { FlashMessage } from 'Types/FlashMessages'
import type { FunctionComponent } from 'react'

interface Props {
  error?: FlashMessage;
  providerLoginPath: string;
  providerPasswordPath: string;
}

const RequestPasswordForm: FunctionComponent<Props> = ({
  error,
  providerLoginPath,
  providerPasswordPath
}) => {
  const [email, setEmail] = useState('')
  const [validationVisibility, setValidationVisibility] = useState(false)

  const handleOnChange = (value: string) => {
    setEmail(value)
    setValidationVisibility(false)
  }

  const handleOnBlur = () => {
    setValidationVisibility(true)
  }

  const emailValidationErrors = validateRequestPassword(email)
  const validatedEmail = (validationVisibility && emailValidationErrors) ? 'error' : 'default'

  return (
    <Form
      noValidate
      acceptCharset="UTF-8"
      action={providerPasswordPath}
      id="request_password"
      method="post"
    >
      <LoginAlert error={error} />

      <input name="utf8" type="hidden" value="✓" />
      <input name="_method" type="hidden" value="delete" />
      <CSRFToken />

      <FormGroup
        isRequired
        autoComplete="off"
        fieldId="email"
        helperTextInvalid={emailValidationErrors?.[0]}
        label="Email address"
        validated={validatedEmail}
      >
        <TextInput
          autoFocus
          isRequired
          autoComplete="off"
          id="email"
          name="email"
          type="email"
          validated={validatedEmail}
          value={email}
          onBlur={handleOnBlur}
          onChange={handleOnChange}
        />
      </FormGroup>

      <ActionGroup>
        <Button
          isBlock
          isDisabled={emailValidationErrors !== undefined}
          type="submit"
          variant="primary"
        >
          Reset password
        </Button>
        <Button
          isBlock
          component="a"
          href={providerLoginPath}
          variant="link"
          // HACK: prevent click from missing link after input loses focus and component re-renders
          onMouseDown={(event) => { event.currentTarget.click() }}
        >
          Sign in
        </Button>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { RequestPasswordForm }
