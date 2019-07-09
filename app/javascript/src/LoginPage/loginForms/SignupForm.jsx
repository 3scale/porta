// @flow

import React, { Component } from 'react'
import {
  Form,
  ActionGroup
} from '@patternfly/react-core'
import {
  HiddenInputs,
  FormGroup
} from 'LoginPage'

type Props = {
  path: string,
  user: {
    email: string,
    username: string,
    firstname: string,
    lastname: string
  }
}

type State = {
  username: string,
  emailAddress: string,
  firstname: string,
  lastname: string,
  password: string,
  passwordConfirmation: string,
  isFilledUsername: ?boolean,
  isFilledEmailAddress: ?boolean,
  isFilledFirstname: boolean,
  isFilledLastname: boolean,
  isFilledPassword: ?boolean,
  isFilledPasswordConfirmation: ?boolean
}

const InputFormGroup = (props) => {
  const { isRequired, type, value, onChange, isValid } = props
  const inputProps = {
    value,
    onChange,
    autoFocus: null,
    inputIsValid: isValid
  }
  return (
    <FormGroup isRequired={isRequired}
      type={type}
      labelIsValid={isValid}
      inputProps={inputProps}
    />
  )
}

class SignupForm extends Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      username: this.props.user.username,
      emailAddress: this.props.user.email,
      firstname: this.props.user.firstname,
      lastname: this.props.user.lastname,
      password: '',
      passwordConfirmation: '',
      isFilledUsername: undefined,
      isFilledEmailAddress: undefined,
      isFilledFirstname: true,
      isFilledLastname: true,
      isFilledPassword: undefined,
      isFilledPasswordConfirmation: undefined
    }
  }

  handleTextInputUsername = (username: string) =>
    this.setState({ username, isFilledUsername: username !== '' })

  handleTextInputEmail = (emailAddress: string) =>
    this.setState({ emailAddress, isFilledEmailAddress: emailAddress !== '' })

  handleTextInputFirstname = (firstname: string) => this.setState({ firstname })

  handleTextInputLastname = (lastname: string) => this.setState({ lastname })

  handleTextInputPassword = (password: string) =>
    this.setState({
      password,
      isFilledPassword: password !== '',
      isFilledPasswordConfirmation: this.state.passwordConfirmation === password
    })

  handleTextInputPasswordConfirmation = (passwordConfirmation: string) =>
    this.setState({
      passwordConfirmation,
      isFilledPasswordConfirmation: passwordConfirmation !== '' && passwordConfirmation === this.state.password
    })

  render () {
    const { username, isFilledUsername, emailAddress, isFilledEmailAddress, firstname, isFilledFirstname, lastname, isFilledLastname, password, isFilledPassword, passwordConfirmation, isFilledPasswordConfirmation } = this.state
    return (
      <Form noValidate={false}
        action={this.props.path}
        id='signup_form'
        acceptCharset='UTF-8'
        method='post'
      >
        <HiddenInputs />
        <InputFormGroup isRequired type='user[username]' value={username} isValid={isFilledUsername} onChange={this.handleTextInputUsername} />
        <InputFormGroup isRequired type='user[email]' value={emailAddress} isValid={isFilledEmailAddress} onChange={this.handleTextInputEmail} />
        <InputFormGroup isRequired={false} type='user[first_name]' value={firstname} isValid={isFilledFirstname} onChange={this.handleTextInputFirstname} />
        <InputFormGroup isRequired={false} type='user[last_name]' value={lastname} isValid={isFilledLastname} onChange={this.handleTextInputLastname} />
        <InputFormGroup isRequired type='user[password]' value={password} isValid={isFilledPassword} onChange={this.handleTextInputPassword} />
        <InputFormGroup isRequired type='user[password_confirmation]' value={passwordConfirmation} isValid={isFilledPasswordConfirmation} onChange={this.handleTextInputPasswordConfirmation} />
        <ActionGroup>
          <input type="submit"
            name="commit"
            value="Sign up"
            className="pf-m-primary pf-c-button pf-m-primary pf-m-block"
          />
        </ActionGroup>
      </Form>
    )
  }
}

export {
  SignupForm
}
