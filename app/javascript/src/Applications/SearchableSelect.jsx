// @flow

import React, { useState } from 'react'

// TODO: import './SearchableSelect.scss'

export interface Option {
  id: string,
  name: string
}

type Props<T> = {
  options: $ReadOnlyArray<T>,
  onOptionSelected: T => void,
  defaultOption?: T,
  formName?: string,
  hint?: string
}

const SearchableSelect = <T: Option>({
  options,
  onOptionSelected,
  defaultOption = options[0],
  formName,
  hint
}: Props<T>) => {
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

const OptionsList = <T: Option>({ options, onClick }: { options: $ReadOnlyArray<T>, onClick: T => void }) => (
  <ul className='OptionsList'>
    {options.length
      ? options.map(o => <li key={o.id} onMouseDown={() => onClick(o)}>{o.name}</li>)
      : <li className='Disabled'>No results found</li>
    }
  </ul>
)

export { SearchableSelect }
