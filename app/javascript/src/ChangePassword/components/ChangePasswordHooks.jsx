import { useState } from 'react'
import { validateForm, validateSingleField } from 'LoginPage/utils/formValidation'

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

const getPasswordConfirmationError = (errors) => {
  const passwordConfirmationError = (errors && errors[PASSWORD_CONFIRMATION]) && errors[PASSWORD_CONFIRMATION][0]
  const passwordsMatchError = passwordConfirmationError && passwordConfirmationError.includes('is not equal to')
  return {
    passwordConfirmationError: !!passwordConfirmationError,
    errorMessage: passwordsMatchError ? 'mustMatch' : 'isMandatory'
  }
}

const comparePasswordsLength = (event) => {
  const passwordInput = event.currentTarget['user_password']
  const passwordConfirmationInput = event.currentTarget['user_password_confirmation']
  return passwordConfirmationInput.value.length >= passwordInput.value.length
}

const useFormState = () => {
  const [isFormDisabled, setIsFormDisabled] = useState(true)
  const [passwordValue, setPasswordValue] = useState('')
  const [isPasswordValid, setIsPasswordValid] = useState(undefined)
  const [passwordConfirmationValue, setPasswordConfirmationValue] = useState('')
  const [isPasswordConfirmationValid, setIsPasswordConfirmationValid] = useState(undefined)
  const [confirmationErrorMessage, setConfirmationErrorMessage] = useState('isMandatory')
  const [validationStarted, setValidationStarted] = useState(false)

  const onFormChange = (event) => {
    const errors = isFormValid(event.currentTarget)
    const { passwordConfirmationError, errorMessage } = getPasswordConfirmationError(errors)
    const initValidation = comparePasswordsLength(event)
    if (initValidation && !validationStarted) {
      setValidationStarted(initValidation)
    }
    if (initValidation || validationStarted) {
      setIsPasswordConfirmationValid(!passwordConfirmationError)
    }
    setConfirmationErrorMessage(errorMessage)
    setIsFormDisabled(!!errors)
  }

  const onPasswordChange = (value, event) => {
    setPasswordValue(value)
    setIsPasswordValid(!!validateSingleField(event))
  }

  const onPasswordBlur = () => setIsPasswordValid(!!isPasswordValid)

  const onPasswordConfirmationChange = (value) => setPasswordConfirmationValue(value)

  const onPasswordConfirmationBlur = () => setIsPasswordConfirmationValid(!isFormDisabled)

  return {
    isFormDisabled,
    confirmationErrorMessage,
    onFormChange,
    password: {
      value: passwordValue,
      isValid: isPasswordValid,
      onChange: onPasswordChange,
      onBlur: onPasswordBlur
    },
    passwordConfirmation: {
      value: passwordConfirmationValue,
      isValid: isPasswordConfirmationValid,
      onChange: onPasswordConfirmationChange,
      onBlur: onPasswordConfirmationBlur
    }
  }
}

export { useFormState }
