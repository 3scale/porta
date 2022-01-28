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
  errors?: FormErrors
}

const EmailConfigurationForm = ({ url, emailConfiguration, errors = {} }: Props): React.Node => {
  const [email, setEmail] = useState<string>(emailConfiguration.email || '')
  const [userName, setUserName] = useState<string>(emailConfiguration.userName || '')
  const [password, setPassword] = useState<string>(emailConfiguration.password || '')
  const [passwordRepeat, setPasswordRepeat] = useState<string>('')

  const emailErrors = errors.email || []
  const userNameErrors = errors.user_name || []
  const passwordErrors = errors.password || []
  const passwordRepeatErrors = []

  // TODO: Implement more validations but let the server do the job when possible

  const isFormValid = passwordRepeat.length && passwordRepeat === password

  return (
    <Form
      id="email-configuration-form"
      acceptCharset='UTF-8'
      method='post'
      action={url}
    >
      <CSRFToken />
      <input name='utf8' type='hidden' value='✓' />

      <EmailInput email={email} setEmail={setEmail} errors={emailErrors} />
      <UserNameInput userName={userName} setUserName={setUserName} errors={userNameErrors} />
      <PasswordInput password={password} setPassword={setPassword} errors={passwordErrors} />
      <PasswordRepeatInput password={passwordRepeat} setPassword={setPasswordRepeat} errors={passwordRepeatErrors} />

      <ActionGroup>
        <Button
          variant='primary'
          type='submit'
          isDisabled={!isFormValid}
        >
          Create Email configuration
        </Button>
      </ActionGroup>
    </Form>
  )
}

export { EmailConfigurationForm }
