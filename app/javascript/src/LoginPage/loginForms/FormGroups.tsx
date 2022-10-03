import {
  FormGroup as PF4FormGroup,
  TextInputProps,
  TextInput
} from '@patternfly/react-core'
import { FunctionComponent } from 'react'
import type { InputProps } from 'Types'

type Props = {
  type?: TextInputProps['type'],
  helperTextInvalid: string,
  inputProps: InputProps
};

const helperTexts = {
  emailOrUsername: 'Email or username is mandatory',
  username: 'Username is mandatory',
  email: 'A valid email address is mandatory',
  firstName: '',
  lastName: '',
  password: 'Password is mandatory',
  passwordConfirmation: {
    isMandatory: 'Password confirmation is mandatory',
    mustMatch: 'Password and Password confirmation must match'
  }
} as const

const FormGroup: FunctionComponent<Props> = ({
  type,
  helperTextInvalid,
  inputProps
}) => {
  const { isRequired, label, fieldId, isValid, name, value, onChange, onBlur, autoFocus, ariaInvalid } = inputProps
  return (
    <>
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
    </>
  )
}

const TextField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => (
  <FormGroup
    type='text'
    inputProps={inputProps}
    helperTextInvalid={helperTexts.emailOrUsername}
  />
)

const EmailField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => (
  <FormGroup
    type='email'
    inputProps={inputProps}
    helperTextInvalid={helperTexts.email}
  />
)

const PasswordField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => {
  const helperText = helperTexts.password
  return (
    <FormGroup
      type='password'
      inputProps={inputProps}
      helperTextInvalid={helperText}
    />
  )
}

const PasswordConfirmationField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => {
  const defaultErrorMessage = helperTexts.passwordConfirmation.isMandatory
  const errorMessage = inputProps.errorMessage as 'isMandatory' | 'mustMatch'
  const helperText = errorMessage ? helperTexts.passwordConfirmation[errorMessage] : defaultErrorMessage
  return (
    <FormGroup
      type='password'
      inputProps={inputProps}
      helperTextInvalid={helperText}
    />
  )
}

export { TextField, EmailField, PasswordField, PasswordConfirmationField }
