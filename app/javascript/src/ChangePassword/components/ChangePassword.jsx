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

const useFormState = () => {
  const [isDisabled, setIsDisabled] = useState(true)

  const onChange = (event) => {
    const errors = isValidForm(event.currentTarget)
    setIsDisabled(!!errors)
  }

  return {
    isDisabled,
    onChange
  }
}

const usePasswordState = () => {
  const [value, setValue] = useState('')
  const [isValid, setIsValid] = useState(undefined)

  const onChange = (value, event) => {
    setValue(value)
    setIsValid(!!validateSingleField(event))
  }

  const onBlur = (event) => {
    const errors = validateSingleField(event)
    setIsValid(!!errors)
  }

  return {
    value,
    isValid,
    onChange,
    onBlur
  }
}

const getPasswordConfirmationErrors = (event) => {
  const errors = isValidForm(event.currentTarget.parentNode.parentNode)
  const passwordConfirmationError = (errors && errors[PASSWORD_CONFIRMATION]) && errors[PASSWORD_CONFIRMATION][0]
  const passwordsMatchError = passwordConfirmationError && passwordConfirmationError.includes('is not equal to')
  return {
    passwordConfirmationError,
    passwordsMatchError
  }
}

const shouldInitValidation = (value, event) => {
  const passwordLength = event.currentTarget.parentNode.parentNode[PASSWORD].value.length
  return value.length >= passwordLength
}

const usePasswordConfirmationState = () => {
  const [value, setValue] = useState('')
  const [isValid, setIsValid] = useState(undefined)
  const [passwordDoesntMatch, setPasswordDoesntMatch] = useState(undefined)
  const [startValidating, setStartValidating] = useState(false)

  const onChange = (value, event) => {
    setValue(value)
    const { passwordConfirmationError, passwordsMatchError } = getPasswordConfirmationErrors(event)
    setPasswordDoesntMatch(passwordsMatchError)
    const initValidation = shouldInitValidation(value, event)
    const validationStarted = startValidating || isValid !== undefined
    setStartValidating(!validationStarted ? initValidation : undefined)
    setIsValid((initValidation || validationStarted) ? !passwordConfirmationError : undefined)
  }

  const onBlur = (event) => {
    const errors = !!isValidForm(event.currentTarget.parentNode.parentNode)
    setIsValid(!errors)
  }

  return {
    value,
    isValid,
    passwordDoesntMatch,
    onChange,
    onBlur
  }
}

const ChangePassword = ({ lostPasswordToken, url, errors }: Props) => {
  const form = useFormState()
  const password = usePasswordState()
  const passwordConfirmation = usePasswordConfirmationState()

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
        onChange={form.onChange}
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
        <PasswordInput
          isRequired
          name='password_confirmation'
          label='Password confirmation'
          value={passwordConfirmation.value}
          isValid={passwordConfirmation.isValid}
          isPasswordConfirmation
          passwordDoesntMatch={passwordConfirmation.passwordDoesntMatch}
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
            isDisabled={form.isDisabled}
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
