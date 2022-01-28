// @flow

import * as React from 'react'
import { useState } from 'react'

import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'
import {
  EmailInput,
  UserNameInput,
  PasswordInput,
  PasswordRepeatInput
} from './form-fields'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FormEmailConfiguration, FormErrors } from 'EmailConfigurations/types'

import './EmailConfigurationForm.scss'

type Props = {
  url: string,
  emailConfiguration: FormEmailConfiguration,
  isUpdate?: boolean,
  errors?: FormErrors
}

const EmailConfigurationForm = ({ url, emailConfiguration, isUpdate = false, errors = {} }: Props): React.Node => {
  const [email, setEmail] = useState<string>(emailConfiguration.email || '')
  const [userName, setUserName] = useState<string>(emailConfiguration.userName || '')
  const [password, setPassword] = useState<string>(emailConfiguration.password || '')
  const [passwordRepeat, setPasswordRepeat] = useState<string>('')

  const emailErrors = errors.email || []
  const userNameErrors = errors.user_name || []
  const passwordErrors = errors.password || []
  const passwordRepeatErrors = []

  // TODO: Implement more validations but let the server do the job when possible

  let isFormValid = false

  if (isUpdate) {
    const isAnyFieldChanged = (email !== emailConfiguration.email) ||
                              (userName !== emailConfiguration.userName) ||
                              (password !== emailConfiguration.password)

    isFormValid = isAnyFieldChanged && (password === emailConfiguration.password || (password !== emailConfiguration.password && passwordRepeat === password))
  } else {
    isFormValid = password.length && passwordRepeat === password
  }

  const buttons = isUpdate ? (
    <>
      <Button
        variant="primary"
        type="submit"
        isDisabled={!isFormValid}
      >
        Update email configuration
      </Button>
      <Button
        variant="danger"
        // type="submit"
      >
        Delete
      </Button>
    </>
  ) : (
    <Button
      variant="primary"
      type="submit"
      isDisabled={!isFormValid}
    >
      Create email configuration
    </Button>
  )

  return (
    <Form
      id="email-configuration-form"
      acceptCharset="UTF-8"
      // id={emailConfiguration.id}
      method="post"
      action={url}
    >
      <CSRFToken />
      <input name="utf8" type="hidden" value="✓" />
      {isUpdate && <input type="hidden" name="_method" value="put" />}

      <EmailInput email={email} setEmail={setEmail} errors={emailErrors} />
      <UserNameInput userName={userName} setUserName={setUserName} errors={userNameErrors} />
      <PasswordInput password={password} setPassword={setPassword} errors={passwordErrors} />
      <PasswordRepeatInput
        password={passwordRepeat}
        setPassword={setPasswordRepeat}
        errors={passwordRepeatErrors}
        isDisabled={isUpdate && password === emailConfiguration.password}
      />

      <ActionGroup>
        {buttons}
      </ActionGroup>
    </Form>
  )
}

export { EmailConfigurationForm }
