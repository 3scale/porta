// @flow

import React from 'react'

import type { Option } from 'NewService/types'

type Props = {
  name: string,
  id: string,
  disabled?: boolean,
  onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  options: Array<Option>
}

const Options = ({options}) => {
  return options.map(option => {
    const { name } = option.metadata
    return <option key={name} value={name}>{name}</option>
  })
}

const Select = ({name, id, disabled, onChange, options}: Props) =>
  <select
    required="required"
    name={name}
    id={id}
    disabled={disabled}
    onChange={onChange}
  >
    <Options options={options}/>
  </select>

export {Select}
