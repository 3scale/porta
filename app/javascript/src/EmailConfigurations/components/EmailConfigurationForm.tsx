import * as React from 'react';
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
};

const EmailConfigurationForm = (
  {
    url,
    emailConfiguration,
    isUpdate = false,
    errors = {},
  }: Props,
): React.ReactElement => {
  const FORM_ID = 'email-configuration-form'
  const [email, setEmail] = useState<string>(emailConfiguration.email || '')
  const [userName, setUserName] = useState<string>(emailConfiguration.userName || '')
  const [password, setPassword] = useState<string>(emailConfiguration.password || '')
  const [passwordRepeat, setPasswordRepeat] = useState<string>('')

  const emailErrors = errors.email || []
  const userNameErrors = errors.user_name || []
  const passwordErrors = errors.password || []
  const passwordRepeatErrors: Array<string> = []

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

  const handleOnDelete = (e: React.SyntheticEvent<HTMLInputElement>) => {
    if (window.confirm('Are you sure?')) {
      const form: HTMLFormElement = document.forms[FORM_ID]
      form.elements.namedItem('_method').value = 'delete';

      form.submit()
    }
  }

  const handleOnUpdate = (e: React.SyntheticEvent<HTMLInputElement>) => {
    const form: HTMLFormElement = document.forms[FORM_ID]
    form.submit()
  }

  const buttons = isUpdate ? (
    <>
      <Button variant="primary" type="submit" onClick={handleOnUpdate} isDisabled={!isFormValid}>Update email configuration</Button>
      <Button variant="danger" type="submit" onClick={handleOnDelete}>Delete</Button>
    </>
  ) : (
    <Button variant="primary" type="submit" isDisabled={!isFormValid}>Create email configuration</Button>
  )

  return (
    <Form
      id={FORM_ID}
      acceptCharset="UTF-8"
      method="post"
      action={url}
      onSubmit={isUpdate ? (e: any) => e.preventDefault() : undefined}
    >
      <CSRFToken />
      <input name="utf8" type="hidden" value="✓" />
      {isUpdate && <input type="hidden" name="_method" value="put" />}

      <EmailInput email={email} setEmail={setEmail} errors={emailErrors} isRequired={!isUpdate} />
      <UserNameInput userName={userName} setUserName={setUserName} errors={userNameErrors} isRequired={!isUpdate} />
      <PasswordInput password={password} setPassword={setPassword} errors={passwordErrors} isRequired={!isUpdate} />
      <PasswordRepeatInput
        password={passwordRepeat}
        setPassword={setPasswordRepeat}
        errors={passwordRepeatErrors}
        isDisabled={isUpdate && password === emailConfiguration.password}
        isRequired={!isUpdate}
      />

      <ActionGroup>
        {buttons}
      </ActionGroup>
    </Form>
  );
}

export { EmailConfigurationForm }
