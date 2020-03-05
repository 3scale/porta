// @flow

import React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { LoginPage, Form, ActionGroup, Button } from '@patternfly/react-core'
import { HiddenInputs, FlashMessages } from 'LoginPage'
import {
  PasswordInput,
  PasswordConfirmationInput,
  useFormState
} from 'ChangePassword'
import type { FlashMessage } from 'Types'

import 'LoginPage/assets/styles/loginPage.scss'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type Props = {
  lostPasswordToken: ?string,
  url: string,
  errors: (?FlashMessage)[]
}

const ChangePassword = ({ lostPasswordToken, url, errors }: Props) => {
  const {
    isFormDisabled,
    confirmationErrorMessage,
    onFormChange,
    password,
    passwordConfirmation
  } = useFormState()

  return (
    <LoginPage
      brandImgSrc={brandImg}
      brandImgAlt='Red Hat 3scale API Management'
      backgroundImgSrc={PF4DownstreamBG}
      backgroundImgAlt='Red Hat 3scale API Management'
      loginTitle='Change Password'
      footer={null}
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
        <PasswordInput
          isRequired
          name='password'
          label='Password'
          value={password.value}
          isValid={password.isValid}
          autoFocus='autoFocus'
          onBlur={password.onBlur}
          onChange={password.onChange}
        />
        <PasswordConfirmationInput
          isRequired
          name='password_confirmation'
          label='Password confirmation'
          value={passwordConfirmation.value}
          isValid={passwordConfirmation.isValid}
          errorMessage={confirmationErrorMessage}
          onBlur={passwordConfirmation.onBlur}
          onChange={passwordConfirmation.onChange}
        />
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

const ChangePasswordWrapper = (props: Props, containerId: string) =>
  createReactWrapper(<ChangePassword {...props} />, containerId)

export { ChangePassword, ChangePasswordWrapper }
