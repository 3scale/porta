// @flow

import React, { useState } from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { LoginPage, Form, ActionGroup, Button } from '@patternfly/react-core'
import { HiddenInputs, FlashMessages } from 'LoginPage'
import { PasswordInput } from 'ChangePassword'
import type { FlashMessage } from 'Types'
import { validateForm, validateSingleField } from 'LoginPage/utils/formValidation'

import 'LoginPage/assets/styles/loginPage.scss'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type Props = {
  lostPasswordToken: ?string,
  url: string,
  errors: (?FlashMessage)[]
}

const PASSWORD = 'user[password]'
const PASSWORD_CONFIRMATION = 'user[password_confirmation]'

const validationConstraints = {
  [PASSWORD]: {
    presence: true,
    length: { minimum: 1 }
  },
  [PASSWORD_CONFIRMATION]: {
    presence: true,
    length: { minimum: 1 },
    equality: PASSWORD
  }
}

const isValidForm = (form) => validateForm(form, validationConstraints)

const ChangePassword = ({ lostPasswordToken, url, errors }: Props) => {
  const [passwordValue, setPasswordValue] = useState('')
  const [isPasswordValid, setIsPasswordValid] = useState(undefined)
  const [passwordConfirmationValue, setPasswordConfirmationValue] = useState('')
  const [isPasswordConfirmationValid, setIsPasswordConfirmationValid] = useState(undefined)
  const [isFormDisabled, setIsFormDisabled] = useState(true)
  const [passwordDoesntMatch, setPasswordDoesntMatch] = useState(undefined)
  const [startValidating, setStartValidating] = useState(false)

  const onPasswordChange = (value, event) => {
    setPasswordValue(value)
    setIsPasswordValid(!!validateSingleField(event))
  }

  const onPasswordConfirmationChange = (value, event) => {
    setPasswordConfirmationValue(value)

    const errors = isValidForm(event.currentTarget.parentNode.parentNode)
    const passwordConfirmationError = (errors && errors[PASSWORD_CONFIRMATION]) && errors[PASSWORD_CONFIRMATION][0]
    const passwordsMatchError = passwordConfirmationError && passwordConfirmationError.includes('is not equal to')
    setPasswordDoesntMatch(passwordsMatchError)

    if (startValidating) {
      setIsPasswordConfirmationValid(!passwordConfirmationError)
    } else {
      const passwordLength = event.currentTarget.parentNode.parentNode[PASSWORD].value.length
      const initValidation = value.length >= passwordLength
      setStartValidating(initValidation)
      setIsPasswordConfirmationValid(initValidation ? !passwordConfirmationError : undefined)
    }
  }

  const onPasswordBlur = (event) => {
    const errors = validateSingleField(event)
    setIsPasswordValid(!!errors)
  }

  const onPasswordConfirmationBlur = (event) => {
    const errors = !!isValidForm(event.currentTarget.parentNode.parentNode)
    setIsPasswordConfirmationValid(!errors)
  }

  const onFormChange = (event) => {
    const errors = isValidForm(event.currentTarget)
    setIsFormDisabled(!!errors)
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
        onChange={onFormChange}
      >
        <input type='hidden' name='_method' value='put' />
        <HiddenInputs />
        <PasswordInput
          isRequired
          name='password'
          label='Password'
          value={passwordValue}
          isValid={isPasswordValid}
          autoFocus='autoFocus'
          onBlur={onPasswordBlur}
          onChange={onPasswordChange}
        />
        <PasswordInput
          isRequired
          name='password_confirmation'
          label='Password confirmation'
          value={passwordConfirmationValue}
          isValid={isPasswordConfirmationValid}
          isPasswordConfirmation
          passwordDoesntMatch={passwordDoesntMatch}
          onBlur={onPasswordConfirmationBlur}
          onChange={onPasswordConfirmationChange}
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
