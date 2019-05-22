// @flow

import React from 'react'

type Option = {
  metadata: {
    name: string
  }
}

type Props = {
  name: string,
  id: string,
  onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  options: Array<Option>
}

const Options = ({options}) => {
  return options.map(option => {
    const { name } = option.metadata
    return <option key={name} value={name}>{name}</option>
  })
}

const Select = ({name, id, onChange, options}: Props) =>
  <select
    required="required"
    name={name}
    id={id}
    onChange={onChange}
  >
    {<Options options={options}/>}
  </select>

export {Select}
