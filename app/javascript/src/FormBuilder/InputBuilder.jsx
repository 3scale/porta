//@flow

import { switchCase, filterKeys } from 'utilities/fp'
import React from 'react'
import {
  FormGroup,
  TextInput,
  FormSelectionOption,
  FormSelect,
  Checkbox,
  Radio
} from '@patternfly/react-core'

type Type = 'text' | 'select' | 'radio' | 'checkbox' | 'hidden'
type Options = {[string]: string}
type Props = {
  settings: {
    label?: string,
    name?: string,
    type?: Type,
    collection?: Options[],
    onChange?: void,
    className?: string,
    isDisabled?: boolean,
    isRequired?: boolean,
    helperText?: string
  },
  value?: string
}

const SettingsTemplate = {
  type: 'text',
  label: '',
  fieldId: ''
}

const COMMON_KEYS: string[] = ['id', 'type', 'onChange', 'value', 'className', 'isDisabled']
const GROUP_KEYS: string[] = ['label', 'isRequired', 'fieldId', 'helperText']
const SELECT_KEYS: string[] = [...COMMON_KEYS, ...['helperText']]
const SELECT_OPTION_KEYS: string[] = ['value', 'label', 'isDisabled', 'key']
const CHECKERS_KEYS: string[] = [...COMMON_KEYS, ...['isChecked', 'name']]


const InputBuilder = ({settings = SettingsTemplate, value = ''}: Props) => {
  const { type, collection } = settings
  return (
    <FormGroup {...filterKeys(settings)(GROUP_KEYS)}>
      {switchCase({
        'text': () => (<TextInput {...filterKeys({...settings, ...{value}})(COMMON_KEYS)}/>),
        'select': () => (
          <FormSelect {...filterKeys({...settings, ...{value}})(SELECT_KEYS)}>
            {collection && collection.map((option, index) =>
              <FormSelectionOption {...filterKeys({...option, ...{key: index}})(SELECT_OPTION_KEYS)} />
            )}
          </FormSelect>
        ),
        'checkbox': () => (<Checkbox {...filterKeys(settings)(CHECKERS_KEYS)} />),
        'radio': () => (<Radio {...filterKeys(settings)(CHECKERS_KEYS)} />)
      })(() => {})(type)()}
    </FormGroup>
  )
}

export {
  InputBuilder
}
