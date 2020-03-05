// @flow

import React from 'react'
import { PasswordField, PasswordConfirmationField } from 'LoginPage'

type Props = {
    isRequired?: boolean,
    name: string,
    label: string,
    value: string,
    isValid: boolean,
    autoFocus?: string,
    errorMessage?: string,
    onChange: () => void,
    onBlur: () => void,
}

const getInputProps = props => ({
  ...props,
  name: `user[${props.name}]`,
  fieldId: `user_${props.name}`
})

const PasswordInput = (props: Props) => (
  <PasswordField inputProps={getInputProps(props)} />
)

const PasswordConfirmationInput = (props: Props) => (
  <PasswordConfirmationField inputProps={getInputProps(props)} />
)

export { PasswordInput, PasswordConfirmationInput }
