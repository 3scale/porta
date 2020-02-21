// @flow

import React from 'react'
import { PasswordField } from 'LoginPage'

type Props = {
  isRequired?: boolean,
  name: string,
  label: string,
  value: string,
  isValid: boolean,
  autoFocus?: string,
  isPasswordConfirmation?: boolean,
  passwordDoesntMatch?: boolean,
  onChange: () => void,
  onBlur: () => void
}

const PasswordInput = ({ isRequired, name, label, value, isValid, autoFocus, isPasswordConfirmation, passwordDoesntMatch, onChange, onBlur }: Props) => {
  const inputProps = {
    isRequired,
    name: `user[${name}]`,
    fieldId: `user_${name}`,
    label,
    value,
    isValid,
    onChange,
    onBlur,
    autoFocus,
    isPasswordConfirmation,
    passwordDoesntMatch
  }

  return (
    <PasswordField inputProps={inputProps} />
  )
}

export { PasswordInput }
