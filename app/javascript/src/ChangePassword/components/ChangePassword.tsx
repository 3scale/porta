import * as React from 'react'
import { createReactWrapper } from 'utilities'
import { LoginPage, Form, ActionGroup, Button } from '@patternfly/react-core'
import { PasswordField, PasswordConfirmationField, HiddenInputs, FlashMessages } from 'LoginPage'
import { useFormState } from 'ChangePassword'
import type { FlashMessage, InputProps } from 'Types'

import 'LoginPage/assets/styles/loginPage.scss'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type Props = {
  lostPasswordToken: string | null | undefined,
  url: string,
  errors?: FlashMessage[]
};

const ChangePassword = (
  {
    lostPasswordToken,
    url,
    errors
  }: Props
): React.ReactElement => {
  const {
    isFormDisabled,
    onFormChange,
    password,
    passwordConfirmation
  } = useFormState()

  const passwordProps: InputProps = {
    isRequired: true,
    name: 'user[password]',
    fieldId: 'user_password',
    label: 'Password',
    value: password.value,
    isValid: password.isValid,
    errorMessage: password.errorMessage,
    autoFocus: 'autoFocus',
    onBlur: password.onBlur,
    onChange: password.onChange
  }

  const passwordConfirmationProps = {
    isRequired: true,
    name: 'user[password_confirmation]',
    fieldId: 'user_password_confirmation',
    label: 'Password confirmation',
    value: passwordConfirmation.value,
    isValid: passwordConfirmation.isValid,
    errorMessage: passwordConfirmation.errorMessage,
    onBlur: passwordConfirmation.onBlur,
    onChange: passwordConfirmation.onChange
  }

  return (
    <LoginPage
      brandImgSrc={brandImg}
      brandImgAlt='Red Hat 3scale API Management'
      backgroundImgSrc={PF4DownstreamBG}
      backgroundImgAlt='Red Hat 3scale API Management'
      loginTitle='Change Password'
    >
      {errors && <FlashMessages flashMessages={errors}/>}
      <Form
        action={url}
        noValidate
        id='edit_user_2'
        acceptCharset='UTF-8'
        method='post'
        onChange={onFormChange}
      >
        <input type='hidden' name='_method' value='put' />
        <HiddenInputs />
        <PasswordField inputProps={passwordProps} />
        <PasswordConfirmationField inputProps={passwordConfirmationProps} />
        {lostPasswordToken &&
          <input id='password_reset_token' type='hidden' name='password_reset_token' value={lostPasswordToken} />
        }
        <ActionGroup>
          <Button
            className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            name='commit'
            isDisabled={isFormDisabled}
          >
            Change Password
          </Button>
        </ActionGroup>
      </Form>
    </LoginPage>
  )
}

const ChangePasswordWrapper = (props: Props, containerId: string): void => createReactWrapper(<ChangePassword {...props} />, containerId)

export { ChangePassword, ChangePasswordWrapper }
