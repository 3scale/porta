// @flow

import { useState } from 'react'
import validate from 'validate.js' // TODO: including this since validateSingleField and validateForm from LoginPage/utils/formValidation screams for a refactor

type FieldName = string
type ValidatorName = 'presence' | 'length' | 'equality'
type ValidatorOption = {message: string, minimun?: number, attribute?: string}
type Constraints = {[FieldName]: {[ValidatorName]: ValidatorOption}}
type FieldState = {[FieldName]: string}
type ValidationErrors = {[FieldName]: string[]}
type FieldErrorsState = ValidationErrors

const PASSWORD: string = 'user[password]'
const PASSWORD_CONFIRMATION: string = 'user[password_confirmation]'

// The following validation objects are tied to FormGroups helperTexts, very closed module, not open to change. TODO: REFACTOR those components
const validationConstraints: Constraints = {
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

const fieldsTemplate: FieldState = {
  [PASSWORD]: '',
  [PASSWORD_CONFIRMATION]: ''
}

const fieldErrorsTemplate: FieldErrorsState = {
  [PASSWORD]: [],
  [PASSWORD_CONFIRMATION]: []
}

const fieldsPristineTemplate: FieldErrorsState = {
  [PASSWORD]: true,
  [PASSWORD_CONFIRMATION]: true
}
const extractFirstErrorMessage = (errorMessageArray: string[]): string => errorMessageArray[0]
const isFieldValid = (errorMessageArray: string[]): boolean => !errorMessageArray.length
const isPassConfirmLongEnough = ({ [PASSWORD]: pass, [PASSWORD_CONFIRMATION]: conf }: FieldState): boolean => (conf.length >= pass.length)

type FormInput = {
  value: string,
  isValid: boolean,
  errorMessage: string,
  onChange: (value: string) => void,
  onBlur: (e: SyntheticInputEvent<HTMLInputElement>) => void
}

type IUseFormState = {
  isFormDisabled: boolean,
  onFormChange: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  password: FormInput,
  passwordConfirmation: FormInput
}

const useFormState = (): IUseFormState => {
  const [fieldValues, setFieldValues] = useState(fieldsTemplate)
  const [fieldErrors, setFieldErrors] = useState(fieldErrorsTemplate)
  const [isFormDisabled, setIsFormDisabled] = useState(true)
  const [areFieldsPristine, setAreFieldsPristine] = useState(fieldsPristineTemplate)

  const onFormChange = (event: SyntheticInputEvent<HTMLInputElement>) => {
    // $FlowIgnore[incompatible-call] we can assume all arguments are correct
    const validationErrors: ValidationErrors = validate(event.currentTarget, validationConstraints)
    const visibleErrors = !!validationErrors && Object.keys(validationErrors)
      .filter(key => !areFieldsPristine[key])
      .filter(key => !key === PASSWORD_CONFIRMATION || isPassConfirmLongEnough(fieldValues))
      .reduce((errors, key) => ({ ...errors, [key]: validationErrors[key] }), {})
    // $FlowExpectedError[cannot-spread-inexact] visibleErrors is supposed to be inexact
    setFieldErrors(visibleErrors ? { ...fieldErrorsTemplate, ...visibleErrors } : fieldErrorsTemplate)
    setIsFormDisabled(!!validationErrors)
  }

  const onFieldChange = (fieldName: FieldName) => (value: string) => {
    setFieldValues({ ...fieldValues, [fieldName]: value })
    setAreFieldsPristine({ ...areFieldsPristine, [fieldName]: false })
  }

  const onFieldBlur = (fieldName: FieldName) => (event: SyntheticInputEvent<HTMLInputElement>) => {
    // $FlowIgnore[incompatible-type] we can assume types here
    const validationErrors: ValidationErrors = validate(
      { ...fieldValues, [fieldName]: event.currentTarget.value },
      { [fieldName]: validationConstraints[fieldName] }
    ) || { [fieldName]: [] }
    setFieldErrors(({ ...fieldErrors, ...validationErrors }))
  }

  const buildFieldProps = (fieldName: FieldName) => (
    {
      value: fieldValues[fieldName],
      isValid: isFieldValid(fieldErrors[fieldName]),
      errorMessage: extractFirstErrorMessage(fieldErrors[fieldName]),
      onChange: onFieldChange(fieldName),
      onBlur: onFieldBlur(fieldName)
    }
  )

  return {
    isFormDisabled,
    onFormChange,
    password: buildFieldProps(PASSWORD),
    passwordConfirmation: buildFieldProps(PASSWORD_CONFIRMATION)
  }
}

export { useFormState }
