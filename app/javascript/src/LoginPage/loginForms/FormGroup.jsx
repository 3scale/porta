// @flow

import React from 'react'
import {
  FormGroup as PF4FormGroup,
  TextInput
} from '@patternfly/react-core'

type Props = {
  isRequired?: boolean,
  type: string,
  labelIsValid: boolean,
  inputProps: {
    value: 'string',
    onChange: () => void,
    autoFocus: 'string',
    inputIsValid: boolean,
    ariaInvalid: boolean
  }
}

const getFormGroupProps = (type: string) => {
  const types = ['username', 'password', 'email', 'user[username]', 'user[email]', 'user[first_name]', 'user[last_name]', 'user[password]', 'user[password_confirmation]']
  const typeIndex = types.indexOf(type)
  const inputTypes = ['text', 'password', 'email', 'text', 'email', 'text', 'text', 'password', 'password']
  const labels = ['Email or Username', 'Password', 'Email address', 'Username', 'Email', 'First name', 'Last name', 'Password', 'Password confirmation']
  const fieldIDs = ['session_username', 'session_password', 'email', 'user_username', 'user_email', 'user_first_name', 'user_last_name', 'user_password', 'user_password_confirmation']
  const helperTextInvalids = ['Email or username is mandatory', 'Password is mandatory', 'A valid email address is mandatory', 'Username is mandatory', 'A valid email is mandatory', '', '', 'Password is mandatory', 'Password confirmation is mandatory']
  const tabIndexs = ['1', '2', '1', null, null, null, null, null, null]
  return {
    label: labels[typeIndex],
    inputType: inputTypes[typeIndex],
    fieldId: fieldIDs[typeIndex],
    helperTextInvalid: helperTextInvalids[typeIndex],
    tabIndex: tabIndexs[typeIndex]
  }
}

const FormGroup = ({isRequired = false, type, labelIsValid, inputProps}: Props) => {
  const {value, onChange, autoFocus, inputIsValid, ariaInvalid} = inputProps
  const {label, inputType, fieldId, helperTextInvalid, tabIndex} = getFormGroupProps(type)
  return (
    <React.Fragment>
      <PF4FormGroup
        label={label}
        isRequired={isRequired}
        fieldId={fieldId}
        helperTextInvalid={helperTextInvalid}
        isValid={labelIsValid}
      >
        <TextInput
          isRequired={isRequired}
          type={inputType}
          id={fieldId}
          name={type}
          tabIndex={tabIndex}
          value={value}
          onChange={onChange}
          autoFocus={autoFocus}
          isValid={inputIsValid}
          aria-invalid={ariaInvalid}
        />
      </PF4FormGroup>
    </React.Fragment>
  )
}

export {FormGroup}
