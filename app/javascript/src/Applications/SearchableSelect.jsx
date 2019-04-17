// @flow

import React, { useState } from 'react'

// TODO: import './SearchableSelect.scss'

export interface Option {
  id: string,
  name: string
}

type Props = {
  options: $ReadOnlyArray<Option>,
  defaultOption?: Option,
  onOptionSelected?: Option => void,
  label: string,
  formId: string,
  formName: string,
  hint?: string
}

const SearchableSelect = ({
  options,
  defaultOption = options[0],
  onOptionSelected,
  label,
  formId,
  formName,
  hint
}: Props) => {
  const [term, setTerm] = useState(defaultOption ? defaultOption.name : '')
  const [showOptions, setShowOptions] = useState(false)
  const [filteredOptions, setFilteredOptions] = useState(options)
  const [selectedOption, setSelectedOption] = useState(defaultOption)

  const onTextChanged = (ev: SyntheticEvent<HTMLInputElement>) => {
    const term = ev.currentTarget.value
    setTerm(term)
    setFilteredOptions(options.filter(o => o.name.toLowerCase().indexOf(term.toLowerCase()) > -1))
  }

  const onFocus = () => setShowOptions(true)

  const onBlur = () => {
    setTerm(selectedOption ? selectedOption.name : '')
    setShowOptions(false)
    setFilteredOptions(options)
  }

  const onOptionClick = option => {
    setSelectedOption(option)
    setShowOptions(false)

    if (onOptionSelected) {
      onOptionSelected(option)
    }
  }

  return (
    <div className='SearchableSelect'>
      <label htmlFor={formId}>{label}</label>
      <input id={formId} name={formName} className='HiddenForm' value={selectedOption.id} readOnly />
      <input
        type='text'
        aria-label={formName}
        placeholder='Select one...'
        value={term}
        onChange={onTextChanged}
        onFocus={onFocus}
        onBlur={onBlur}
      />
      {showOptions && <OptionsList options={filteredOptions} onClick={onOptionClick} />}
      {hint && <p className="inline-hints">{hint}</p>}
    </div>
  )
}

const OptionsList = ({ options, onClick }: {options: $ReadOnlyArray<Option>, onClick: Option => void}) => (
  <ul className='OptionsList'>
    {options.length
      ? options.map(o => <li key={o.id} onMouseDown={() => onClick(o)}>{o.name}</li>)
      : <li className='Disabled'>No results found</li>
    }
  </ul>
)

export { SearchableSelect }
