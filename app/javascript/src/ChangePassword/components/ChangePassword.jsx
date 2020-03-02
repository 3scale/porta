// @flow

import React, { useState } from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { LoginPage, Form, ActionGroup, Button } from '@patternfly/react-core'
import { HiddenInputs, FlashMessages } from 'LoginPage'
import { PasswordInput, PasswordConfirmationInput } from 'ChangePassword'
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

const isFormValid = (formNode) => validateForm(formNode, validationConstraints)

const useFormState = (formNode) => {
  const [isDisabled, setIsDisabled] = useState(true)

  const onChange = () => {
    const errors = isFormValid(formNode)
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

const getPasswordConfirmationErrors = (formNode) => {
  const errors = isFormValid(formNode)
  const passwordConfirmationError = (errors && errors[PASSWORD_CONFIRMATION]) && errors[PASSWORD_CONFIRMATION][0]
  const passwordsMatchError = passwordConfirmationError && passwordConfirmationError.includes('is not equal to')
  return {
    hasError: !!passwordConfirmationError,
    errorMessage: passwordsMatchError ? 'mustMatch' : 'isMandatory'
  }
}

const compareInputsLength = (value) => {
  const passwordInput = document.querySelector('input#user_password')
  const passwordLength = passwordInput instanceof HTMLInputElement ? passwordInput.value.length : 0
  return value.length >= passwordLength
}

const usePasswordConfirmationState = (formNode) => {
  const [value, setValue] = useState('')
  const [isValid, setIsValid] = useState(undefined)
  const [errorMessage, setErrorMessage] = useState('isMandatory')
  const [startValidating, setStartValidating] = useState(false)

  const onChange = (value, event) => {
    setValue(value)
    const { hasError, errorMessage } = getPasswordConfirmationErrors(formNode)
    setErrorMessage(errorMessage)
    const initValidation = compareInputsLength(value)
    const validationStarted = startValidating || isValid !== undefined
    setStartValidating(!validationStarted ? initValidation : undefined)
    setIsValid((initValidation || validationStarted) ? !hasError : undefined)
  }

  const onBlur = () => {
    const errors = !!isFormValid(formNode)
    setIsValid(!errors)
  }

  return {
    value,
    isValid,
    errorMessage,
    onChange,
    onBlur
  }
}

const ChangePassword = ({ lostPasswordToken, url, errors }: Props) => {
  const formNode = document.querySelector('form')
  const form = useFormState(formNode)
  const password = usePasswordState()
  const passwordConfirmation = usePasswordConfirmationState(formNode)

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
        <PasswordConfirmationInput
          isRequired
          name='password_confirmation'
          label='Password confirmation'
          value={passwordConfirmation.value}
          isValid={passwordConfirmation.isValid}
          errorMessage={passwordConfirmation.errorMessage}
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
