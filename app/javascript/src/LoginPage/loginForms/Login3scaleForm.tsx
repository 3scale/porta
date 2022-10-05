import React from 'react'
import {
  ActionGroup,
  Button,
  Form
} from '@patternfly/react-core'
import { TextField, PasswordField } from 'LoginPage/loginForms/FormGroups'
import { HiddenInputs } from 'LoginPage/loginForms/HiddenInputs'
import { validateSingleField } from 'LoginPage/utils/formValidation'

type Props = {
  providerSessionsPath: string,
  session: {
    username: string | null | undefined
  }
}

type State = {
  username: string,
  password: string,
  validation: {
    username?: boolean,
    password?: boolean
  }
}

const USERNAME_ATTRS = {
  name: 'username',
  fieldId: 'session_username',
  label: 'Email or Username'
}

const PASSWORD_ATTRS = {
  name: 'password',
  fieldId: 'session_password',
  label: 'Password'
}

class Login3scaleForm extends React.Component<Props, State> {
  state: State = {
    username: this.props.session.username || '',
    password: '',
    validation: {
      username: this.props.session.username ? true : undefined,
      password: undefined
    }
  }

  handleInputChange: (arg1: string, arg2: React.SyntheticEvent<HTMLInputElement>) => void = (value, event) => {
    const isValid = validateSingleField(event)
    const validation = {
      ...this.state.validation,
      [event.currentTarget.name]: isValid
    }
    this.setState({
      [event.currentTarget.name]: value,
      validation
    } as State)
  }

  render () {
    const { username, password, validation } = this.state
    const usernameInputProps = {
      isRequired: true,
      name: USERNAME_ATTRS.name,
      fieldId: USERNAME_ATTRS.fieldId,
      label: USERNAME_ATTRS.label,
      isValid: validation.username,
      value: username,
      onChange: this.handleInputChange,
      autoFocus: !username
    } as const
    const passwordInputProps = {
      isRequired: true,
      name: PASSWORD_ATTRS.name,
      fieldId: PASSWORD_ATTRS.fieldId,
      label: PASSWORD_ATTRS.label,
      isValid: validation.password,
      value: password,
      onChange: this.handleInputChange,
      autoFocus: Boolean(username)
    } as const
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)
    return (
      <Form
        noValidate
        acceptCharset='UTF-8'
        action={this.props.providerSessionsPath}
        autoComplete="off"
        id='new_session'
        method='post'
      >
        <HiddenInputs />
        {/* <TextField inputProps={usernameInputProps} autoComplete="off"/> TODO: verify autocomplete did nothing */}
        <TextField inputProps={usernameInputProps} />
        {/* <PasswordField inputProps={passwordInputProps} autoComplete="off"/> TODO: verify autocomplete did nothing */}
        <PasswordField inputProps={passwordInputProps} />
        <ActionGroup>
          <Button
            className='pf-c-button pf-m-primary pf-m-block'
            isDisabled={formDisabled}
            type='submit'
          > Sign in
          </Button>
        </ActionGroup>
      </Form>
    )
  }
}

export { Login3scaleForm, Props }
