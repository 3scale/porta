import { useState } from 'react'
import validate from 'validate.js' // TODO: including this since validateSingleField and validateForm from LoginPage/utils/formValidation screams for a refactor

const PASSWORD = 'user[password]'
const PASSWORD_CONFIRMATION = 'user[password_confirmation]'

// The following validation objects are tied to FormGroups helperTexts, very closed module, not open to change. TODO: REFACTOR those components
const validationConstraints = {
  [PASSWORD]: {
    presence: {
      message: '^isMandatory'
    },
    length: {
      minimum: 1,
      message: '^password'
    }
  },
  [PASSWORD_CONFIRMATION]: {
    presence: {
      message: '^isMandatory'
    },
    length: {
      minimum: 1,
      message: '^isMandatory'
    },
    equality: {
      attribute: PASSWORD,
      message: '^mustMatch'
    }
  }
}

const fieldsTemplate = {
  [PASSWORD]: '',
  [PASSWORD_CONFIRMATION]: ''
}

const extractErrorMessage = errorMessageArray => errorMessageArray.slice(0, 1).pop()
const checkFieldErrors = fieldErrors => fieldName => !(fieldErrors && !!fieldErrors[fieldName])
const validateFields = fieldsNode => validate(fieldsNode, validationConstraints)
const parseValidationErrors = validationErrors => (
  validationErrors
    ? Object.keys(validationErrors)
      .reduce((acc, cur) => ({ ...acc, [cur]: extractErrorMessage(validationErrors[cur]) }), {})
    : fieldsTemplate
)

const useFormState = () => {
  const [fieldValues, setFieldValues] = useState(fieldsTemplate)
  const [fieldErrors, setFieldErrors] = useState(fieldsTemplate)
  const [isFormDisabled, setIsFormDisabled] = useState(true)

  const isFieldValid = checkFieldErrors(fieldErrors)
  const updateForm = errors => {
    setFieldErrors(parseValidationErrors(errors))
    setIsFormDisabled(!!errors)
  }

  const onFormChange = event => updateForm(validateFields(event.currentTarget))
  const onFieldChange = fieldName => value => setFieldValues({...fieldValues, [fieldName]: value})
  const onFieldBlur = fieldName => event => (
    updateForm(validateFields({...fieldValues, [fieldName]: event.currentTarget.value}))
  )

  return {
    isFormDisabled,
    onFormChange,
    password: {
      value: fieldValues[PASSWORD],
      isValid: isFieldValid(PASSWORD),
      errorMessage: fieldErrors[PASSWORD],
      onChange: onFieldChange(PASSWORD),
      onBlur: onFieldBlur(PASSWORD)
    },
    passwordConfirmation: {
      value: fieldValues[PASSWORD_CONFIRMATION],
      isValid: isFieldValid(PASSWORD_CONFIRMATION),
      errorMessage: fieldErrors[PASSWORD_CONFIRMATION],
      onChange: onFieldChange(PASSWORD_CONFIRMATION),
      onBlur: onFieldBlur(PASSWORD_CONFIRMATION)
    }
  }
}

export { useFormState }
