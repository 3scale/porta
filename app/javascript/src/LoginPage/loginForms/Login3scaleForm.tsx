import React from 'react';
import type { ReactNode } from 'react'

import {
  HiddenInputs,
  TextField,
  PasswordField,
  validateSingleField
} from 'LoginPage'

import {
  Form,
  ActionGroup,
  Button
} from '@patternfly/react-core'

type Props = {
  providerSessionsPath: string,
  session: {
    username: string | null | undefined
  }
};

type State = {
  username: string,
  password: string,
  validation: {
    username?: boolean,
    password?: boolean
  }
};

const USERNAME_ATTRS = {
  name: 'username',
  fieldId: 'session_username',
  label: 'Email or Username'
} as const

const PASSWORD_ATTRS = {
  name: 'password',
  fieldId: 'session_password',
  label: 'Password'
} as const

class Login3scaleForm extends React.Component<Props, State> {
  state: State = {
    username: this.props.session.username || '',
    password: '',
    validation: {
      username: this.props.session.username ? true : undefined,
      password: undefined
    }
  };

  handleInputChange: (arg1: string, arg2: React.SyntheticEvent<HTMLInputElement>) => void = (value, event) => {
    const isValid = validateSingleField(event)
    const validation = {
      ...this.state.validation,
      [event.currentTarget.name]: isValid
    } as const
    this.setState({
      [event.currentTarget.name]: value,
      validation
    })
  };

  render(): Node {
    const {username, password, validation} = this.state
    const usernameInputProps = {
      isRequired: true,
      name: USERNAME_ATTRS.name,
      fieldId: USERNAME_ATTRS.fieldId,
      label: USERNAME_ATTRS.label,
      isValid: validation.username,
      value: username,
      onChange: this.handleInputChange,
      autoFocus: username ? false : 'autoFocus'
    } as const
    const passwordInputProps = {
      isRequired: true,
      name: PASSWORD_ATTRS.name,
      fieldId: PASSWORD_ATTRS.fieldId,
      label: PASSWORD_ATTRS.label,
      isValid: validation.password,
      value: password,
      onChange: this.handleInputChange,
      autoFocus: username ? 'autoFocus' : false
    } as const
    const formDisabled = Object.values(this.state.validation).some(value => value !== true)
    return (
      <Form noValidate
        action={this.props.providerSessionsPath}
        id='new_session'
        acceptCharset='UTF-8'
        method='post'
        autoComplete="off"
      >
        <HiddenInputs/>
        <TextField inputProps={usernameInputProps} autoComplete="off"/>
        <PasswordField inputProps={passwordInputProps} autoComplete="off"/>
        <ActionGroup>
          <Button className='pf-c-button pf-m-primary pf-m-block'
            type='submit'
            isDisabled={formDisabled}
          > Sign in</Button>
        </ActionGroup>
      </Form>
    )
  }
}

export {
  Login3scaleForm
}
