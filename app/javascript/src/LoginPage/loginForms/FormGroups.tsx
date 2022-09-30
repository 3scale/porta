import {
  FormGroup as PF4FormGroup,
  TextInput
} from '@patternfly/react-core'
import type { InputProps } from 'Types'
import type { TextInputProps } from '@patternfly/react-core'

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

const FormGroup = ({
  type,
  helperTextInvalid,
  inputProps
}: Props) => {
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

const TextField = (
  {
    inputProps
  }: {
    inputProps: InputProps
  }
): React.ReactElement => {
  return (
    <FormGroup
      type='text'
      inputProps={inputProps}
      helperTextInvalid={helperTexts.emailOrUsername}
    />
  )
}

const EmailField = (
  {
    inputProps
  }: {
    inputProps: InputProps
  }
): React.ReactElement => {
  return (
    <FormGroup
      type='email'
      inputProps={inputProps}
      helperTextInvalid={helperTexts.email}
    />
  )
}

const PasswordField = (
  {
    inputProps
  }: {
    inputProps: InputProps
  }
): React.ReactElement => {
  const helperText = helperTexts.password
  return (
    <FormGroup
      type='password'
      inputProps={inputProps}
      helperTextInvalid={helperText}
    />
  )
}

const PasswordConfirmationField = (
  {
    inputProps
  }: {
    inputProps: InputProps
  }
): React.ReactElement => {
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
