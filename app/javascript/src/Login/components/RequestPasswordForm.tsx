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

  const onEmailChange = (value: string) => {
    setEmail(value)
    setValidationVisibility(false)
  }

  const emailValidation = validateRequestPassword(email)

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
        helperTextInvalid={emailValidation?.[0]}
        label="Email address"
        validated={(validationVisibility && emailValidation) ? 'error' : 'default'}
      >
        <TextInput
          autoFocus
          isRequired
          autoComplete="off"
          id="email"
          name="email"
          type="email"
          validated={(validationVisibility && emailValidation) ? 'error' : 'default'}
          value={email}
          onBlur={() => { setValidationVisibility(true) }}
          onChange={onEmailChange}
        />
      </FormGroup>

      <ActionGroup>
        <Button
          isBlock
          isDisabled={emailValidation !== undefined}
          type="submit"
          variant="primary"
        >
          Reset password
        </Button>
        <a
          className="pf-c-button pf-m-link pf-m-block"
          href={providerLoginPath}
          // HACK: prevent click from missing link after input loses focus and component re-renders
          onMouseDown={(event) => { event.currentTarget.click() }}
        >
          Sign in
        </a>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { RequestPasswordForm }
