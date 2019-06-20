// @flow

import React from 'react'
import {
  FormGroup as PF4FormGroup,
  TextInput
} from '@patternfly/react-core'

type Props = {
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
  const types = ['username', 'password', 'email']
  const typeIndex = types.indexOf(type)
  const inputTypes = ['text', 'password', 'email']
  const labels = ['Email or Username', 'Password', 'Email address']
  const fieldIDs = ['session_username', 'session_password', 'email']
  const helperTextInvalids = ['Email or username is mandatory', 'Password is mandatory', 'A valid email address is mandatory']
  const tabIndexs = ['1', '2', '1']
  return {
    label: labels[typeIndex],
    inputType: inputTypes[typeIndex],
    fieldId: fieldIDs[typeIndex],
    helperTextInvalid: helperTextInvalids[typeIndex],
    tabIndex: tabIndexs[typeIndex]
  }
}

const FormGroup = ({type, labelIsValid, inputProps}: Props) => {
  const {value, onChange, autoFocus, inputIsValid, ariaInvalid} = inputProps
  const {label, inputType, fieldId, helperTextInvalid, tabIndex} = getFormGroupProps(type)
  return (
    <React.Fragment>
      <PF4FormGroup
        label={label}
        isRequired
        fieldId={fieldId}
        helperTextInvalid={helperTextInvalid}
        isValid={labelIsValid}
      >
        <TextInput
          isRequired
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
