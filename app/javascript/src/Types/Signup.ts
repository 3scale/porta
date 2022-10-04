import type { AllHTMLAttributes } from 'react'
import type { FlashMessage } from 'Types'

export type SignupProps = {
  name?: string,
  path: string,
  user: {
    email: string,
    firstname: string,
    lastname: string,
    username: string,
    errors?: FlashMessage[]
  }
}

export type InputProps = {
  isRequired: boolean,
  label: string,
  fieldId: string,
  isValid?: boolean,
  name: string,
  value: string,
  onChange?: (value: string, event: React.SyntheticEvent<HTMLInputElement>) => void,
  onBlur?: (e: React.ChangeEvent<HTMLInputElement>) => void,
  autoFocus?: AllHTMLAttributes<HTMLInputElement>['autoFocus'],
  ariaInvalid?: boolean,
  errorMessage?: string
}

export type InputType = 'username' | 'email' | 'firstName' | 'lastName' | 'password' | 'passwordConfirmation'
