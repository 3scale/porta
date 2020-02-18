// @flow

import React, { useState } from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { LoginPage, Form, ActionGroup, Button } from '@patternfly/react-core'
import { HiddenInputs, FlashMessages } from 'LoginPage'
import { PasswordInput } from 'ChangePassword'
import type { FlashMessage } from 'Types'
import { validateForm } from 'LoginPage/utils/formValidation'

import 'LoginPage/assets/styles/loginPage.scss'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type Props = {
  lostPasswordToken: ?string,
  url: string,
  errors: (?FlashMessage)[]
}

const validationConstraints = {
  'user[password]': {
    presence: true,
    length: { minimum: 1 }
  },
  'user[password_confirmation]': {
    presence: true,
    length: { minimum: 1 },
    equality: 'user[password]'
  }
}

const ChangePassword = ({ lostPasswordToken, url, errors }: Props) => {
  const [isFormDisabled, setIsFormDisabled] = useState(true)
  const [passwordsMatch, setPasswordsMatch] = useState(true)

  const onChange = (event) => {
    const errors = validateForm(event.currentTarget, validationConstraints)
    const passwordConfirmationError = (errors && errors['user[password_confirmation]']) ? errors['user[password_confirmation]'][0] : ''
    const doesPasswordsMatch = !passwordConfirmationError.includes('is not equal to')
    setIsFormDisabled(!!errors)
    setPasswordsMatch(doesPasswordsMatch)
  }

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
        onChange={onChange}
      >
        <input type='hidden' name='_method' value='put' />
        <HiddenInputs />
        <PasswordInput
          isRequired
          name='password'
          label='Password'
          autoFocus='autoFocus'
        />
        <PasswordInput
          isRequired
          name='password_confirmation'
          label='Password confirmation'
        />
        {!passwordsMatch &&
          <div className="pf-c-form__helper-text pf-m-error" aria-live="polite">Password and password confirmation must match</div>
        }
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
