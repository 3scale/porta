import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'

import { CSRFToken } from 'utilities/CSRFToken'
import { EmailInput } from 'EmailConfigurations/components/form-fields/EmailInput'
import { PasswordInput } from 'EmailConfigurations/components/form-fields/PasswordInput'
import { PasswordRepeatInput } from 'EmailConfigurations/components/form-fields/PasswordRepeatInput'
import { UserNameInput } from 'EmailConfigurations/components/form-fields/UserNameInput'

import type { FunctionComponent, FormEvent } from 'react'
import type { FormEmailConfiguration, FormErrors } from 'EmailConfigurations/types'

import './EmailConfigurationForm.scss'

interface Props {
  url: string;
  emailConfiguration: FormEmailConfiguration;
  isUpdate?: boolean;
  errors?: FormErrors;
}

const EmailConfigurationForm: FunctionComponent<Props> = ({
  url,
  emailConfiguration,
  isUpdate = false,
  errors = {}
}) => {
  const FORM_ID = 'email-configuration-form'
  const [email, setEmail] = useState<string>(emailConfiguration.email ?? '')
  const [userName, setUserName] = useState<string>(emailConfiguration.userName ?? '')
  const [password, setPassword] = useState<string>(emailConfiguration.password ?? '')
  const [passwordRepeat, setPasswordRepeat] = useState<string>('')

  const emailErrors = errors.email ?? []
  const userNameErrors = errors.user_name ?? []
  const passwordErrors = errors.password ?? []
  const passwordRepeatErrors: string[] = []

  // TODO: Implement more validations but let the server do the job when possible

  let isFormValid = false

  if (isUpdate) {
    const isAnyFieldChanged = (email !== emailConfiguration.email) ||
                              (userName !== emailConfiguration.userName) ||
                              (password !== emailConfiguration.password)

    isFormValid = isAnyFieldChanged && (password === emailConfiguration.password || (password !== emailConfiguration.password && passwordRepeat === password))
  } else {
    isFormValid = password.length > 0 && passwordRepeat === password
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Form defined in this very component
  const getForm = () => document.forms.namedItem(FORM_ID)!

  const handleOnDelete = () => {
    if (window.confirm('Are you sure?')) {
      const form = getForm()
      ;(form.elements.namedItem('_method') as HTMLInputElement).value = 'delete'

      form.submit()
    }
  }

  const handleOnUpdate = () => {
    getForm().submit()
  }

  const buttons = isUpdate ? (
    <>
      <Button isDisabled={!isFormValid} type="submit" variant="primary" onClick={handleOnUpdate}>Update email configuration</Button>
      <Button type="submit" variant="danger" onClick={handleOnDelete}>Delete</Button>
    </>
  ) : (
    <Button isDisabled={!isFormValid} type="submit" variant="primary">Create email configuration</Button>
  )

  return (
    <Form
      acceptCharset="UTF-8"
      action={url}
      id={FORM_ID}
      method="post"
      onSubmit={isUpdate ? (e: FormEvent<HTMLFormElement>) => { e.preventDefault() } : undefined}
    >
      <CSRFToken />
      <input name="utf8" type="hidden" value="✓" />
      {isUpdate && <input name="_method" type="hidden" value="put" />}

      <EmailInput email={email} errors={emailErrors} isRequired={!isUpdate} setEmail={setEmail} />
      <UserNameInput errors={userNameErrors} isRequired={!isUpdate} setUserName={setUserName} userName={userName} />
      <PasswordInput errors={passwordErrors} isRequired={!isUpdate} password={password} setPassword={setPassword} />
      <PasswordRepeatInput
        errors={passwordRepeatErrors}
        isDisabled={isUpdate && password === emailConfiguration.password}
        isRequired={!isUpdate}
        password={passwordRepeat}
        setPassword={setPasswordRepeat}
      />

      <ActionGroup>
        {buttons}
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { EmailConfigurationForm }
