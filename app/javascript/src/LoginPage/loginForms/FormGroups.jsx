// @flow

import React from 'react'
import {
  FormGroup as PF4FormGroup,
  TextInput
} from '@patternfly/react-core'

type InputProps = {
  isRequired: boolean,
  label: string,
  fieldId: 'string',
  isValid: boolean,
  name: string,
  value: string,
  onChange?: () => void,
  onBlur?: () => void,
  autoFocus?: string,
  ariaInvalid?: boolean,
  isPasswordConfirmation?: boolean,
  passwordDoesntMatch?: boolean
}

type Props = {
  type: string,
  helperTextInvalid: string,
  inputProps: InputProps
}

const helperTexts = {
  emailOrUsername: 'Email or username is mandatory',
  username: 'Username is mandatory',
  email: 'A valid email address is mandatory',
  firstName: '',
  lastName: '',
  password: 'Password is mandatory',
  passwordConfirmation: 'Password confirmation is mandatory',
  passwordDoesntMatch: 'Password and Password confirmation must match'
}

const FormGroup = ({type, helperTextInvalid, inputProps}: Props) => {
  const {isRequired, label, fieldId, isValid, name, value, onChange, onBlur, autoFocus, ariaInvalid} = inputProps
  return (
    <React.Fragment>
      <PF4FormGroup
        isRequired={isRequired}
        label={label}
        fieldId={fieldId}
        helperTextInvalid={helperTextInvalid}
        isValid={isValid}
      >
        <TextInput
          type={type}
          name={name}
          isRequired={isRequired}
          id={fieldId}
          value={value}
          onChange={onChange}
          onBlur={onBlur}
          autoFocus={autoFocus}
          isValid={isValid}
          aria-invalid={ariaInvalid}
        />
      </PF4FormGroup>
    </React.Fragment>
  )
}

const TextField = ({inputProps}: {inputProps: InputProps}) => {
  return (
    <FormGroup
      type='text'
      inputProps={inputProps}
      helperTextInvalid={helperTexts.emailOrUsername}
    />
  )
}

const EmailField = ({inputProps}: {inputProps: InputProps}) => {
  return (
    <FormGroup
      type='email'
      inputProps={inputProps}
      helperTextInvalid={helperTexts.email}
    />
  )
}

const PasswordField = ({inputProps}: {inputProps: InputProps}) => {
  const isPasswordConfirmation = inputProps.isPasswordConfirmation
  let helperText = helperTexts.password
  if (isPasswordConfirmation) {
    helperText = inputProps.passwordDoesntMatch ? helperTexts.passwordDoesntMatch : helperTexts.passwordConfirmation
  }

  return (
    <FormGroup
      type='password'
      inputProps={inputProps}
      helperTextInvalid={helperText}
    />
  )
}

export {TextField, PasswordField, EmailField}
