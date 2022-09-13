import { useState } from 'react'
import validate from 'validate.js' // TODO: including this since validateSingleField and validateForm from LoginPage/utils/formValidation screams for a refactor

type ValidatorName = 'presence' | 'length' | 'equality';
type ValidatorOption = {
  message: string,
  minimum?: number,
  attribute?: string
};
type Constraints = Record<string, Partial<Record<ValidatorName, ValidatorOption>>>
type FieldState = Record<string, string>
type ValidationErrors = Record<string, string[]>
type FieldErrorsState = ValidationErrors;
type FieldErrorsPristineState = Record<string, boolean>

const PASSWORD = 'user[password]'
const PASSWORD_CONFIRMATION = 'user[password_confirmation]'

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

const fieldsPristineTemplate: FieldErrorsPristineState = {
  [PASSWORD]: true,
  [PASSWORD_CONFIRMATION]: true
}
const extractFirstErrorMessage = (errorMessageArray: string[]): string => errorMessageArray[0]
const isFieldValid = (errorMessageArray: string[]): boolean => !errorMessageArray.length
const isPassConfirmLongEnough = (
  {
    [PASSWORD]: pass,
    [PASSWORD_CONFIRMATION]: conf
  }: FieldState
): boolean => conf.length >= pass.length

type FormInput = {
  value: string,
  isValid: boolean,
  errorMessage: string,
  onChange: (value: string) => void,
  onBlur: (e: React.ChangeEvent<HTMLInputElement>) => void
};

type IUseFormState = {
  isFormDisabled: boolean,
  onFormChange: (e: React.FormEvent<HTMLFormElement>) => void,
  password: FormInput,
  passwordConfirmation: FormInput
};

const useFormState = (): IUseFormState => {
  const [fieldValues, setFieldValues] = useState(fieldsTemplate)
  const [fieldErrors, setFieldErrors] = useState(fieldErrorsTemplate)
  const [isFormDisabled, setIsFormDisabled] = useState(true)
  const [areFieldsPristine, setAreFieldsPristine] = useState(fieldsPristineTemplate)

  const onFormChange: React.FormEventHandler<HTMLFormElement> = (event: React.FormEvent<HTMLFormElement>) => {
    const validationErrors: ValidationErrors = validate(event.currentTarget, validationConstraints)
    const visibleErrors = !!validationErrors && Object.keys(validationErrors)
      .filter(key => !areFieldsPristine[key])
      .filter(key => !(key === PASSWORD_CONFIRMATION) || isPassConfirmLongEnough(fieldValues))
      .reduce<Record<string, any>>((errors, key) => ({ ...errors, [key]: validationErrors[key] }), {})
    setFieldErrors(visibleErrors ? { ...fieldErrorsTemplate, ...visibleErrors } : fieldErrorsTemplate)
    setIsFormDisabled(!!validationErrors)
  }

  const onFieldChange = (fieldName: string) => (value: string) => {
    setFieldValues({ ...fieldValues, [fieldName]: value })
    setAreFieldsPristine({ ...areFieldsPristine, [fieldName]: false })
  }

  const onFieldBlur = (fieldName: string) => (event: React.ChangeEvent<HTMLInputElement>) => {
    const validationErrors: ValidationErrors = validate(
      { ...fieldValues, [fieldName]: event.currentTarget.value },
      { [fieldName]: validationConstraints[fieldName] }
    ) || { [fieldName]: [] }
    setFieldErrors(({ ...fieldErrors, ...validationErrors }))
  }

  const buildFieldProps = (fieldName: string) => (
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
