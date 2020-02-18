// @flow

import React, { useState } from 'react'
import { PasswordField, validateSingleField } from 'LoginPage'

type Props = {
  isRequired?: boolean,
  name: string,
  label: string,
  autoFocus?: string
}

const PasswordInput = ({ isRequired, name, label, autoFocus }: Props) => {
  const [value, setValue] = useState('')
  const [isValid, setIsValid] = useState(undefined)

  const inputProps = {
    isRequired,
    name: `user[${name}]`,
    fieldId: `user_${name}`,
    label,
    value,
    isValid,
    onChange: (value, event) => {
      const isValid = validateSingleField(event)
      setValue(value)
      setIsValid(isValid)
    },
    autoFocus
  }

  return (
    <PasswordField inputProps={inputProps} />
  )
}

export { PasswordInput }
