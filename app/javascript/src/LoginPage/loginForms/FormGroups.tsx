import {
  FormGroup as PF4FormGroup,
  TextInput
} from '@patternfly/react-core'

import type { TextInputProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'
import type { InputProps } from 'Types'

interface Props {
  type?: TextInputProps['type'];
  helperTextInvalid: string;
  inputProps: InputProps;
}

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
    <PF4FormGroup
      autoComplete="off"
      fieldId={fieldId}
      helperTextInvalid={helperTextInvalid}
      isRequired={isRequired}
      isValid={isValid}
      label={label}
    >
      <TextInput
        aria-invalid={ariaInvalid}
        autoComplete="off"
        autoFocus={autoFocus}
        id={fieldId}
        isRequired={isRequired}
        isValid={isValid}
        name={name}
        type={type}
        value={value}
        onBlur={onBlur}
        onChange={onChange}
      />
    </PF4FormGroup>
  )
}

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const TextField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => (
  <FormGroup
    helperTextInvalid={helperTexts.emailOrUsername}
    inputProps={inputProps}
    type="text"
  />
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const EmailField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => (
  <FormGroup
    helperTextInvalid={helperTexts.email}
    inputProps={inputProps}
    type="email"
  />
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const PasswordField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => {
  const helperText = helperTexts.password
  return (
    <FormGroup
      helperTextInvalid={helperText}
      inputProps={inputProps}
      type="password"
    />
  )
}

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const PasswordConfirmationField: FunctionComponent<{ inputProps: InputProps }> = ({ inputProps }) => {
  const defaultErrorMessage = helperTexts.passwordConfirmation.isMandatory
  const errorMessage = inputProps.errorMessage as keyof typeof helperTexts['passwordConfirmation']
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- FIXME: properly type errorMessage
  const helperText = errorMessage ? helperTexts.passwordConfirmation[errorMessage] : defaultErrorMessage
  return (
    <FormGroup
      helperTextInvalid={helperText}
      inputProps={inputProps}
      type="password"
    />
  )
}

export { TextField, EmailField, PasswordField, PasswordConfirmationField }
