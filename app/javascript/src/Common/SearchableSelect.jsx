import React from 'react'
import { TextInput } from '@patternfly/react-core'

import './SearchableSelect.scss'

class SearchableSelect extends React.Component {
  constructor (props) {
    super(props)
    const { options = [], defaultOption = options[0] || {} } = this.props

    this.state = {
      searchTerm: defaultOption.name || '',
      showOptions: false,
      options,
      selectedOption: defaultOption
    }
  }

  onTextChange = (searchTerm) => {
    const filteredOptions = this.props.options.filter(o => o.name.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
    this.setState({ searchTerm, options: filteredOptions })
  }

  onFocus = () => this.setState({ showOptions: true })

  onBlur = () => {
    this.setState({
      searchTerm: this.state.selectedOption.name,
      showOptions: false,
      options: this.props.options
    })
  }

  onOptionSelect = (selectedOption) => {
    if (this.props.onOptionSelect) {
      this.props.onOptionSelect(selectedOption)
    }

    this.setState({
      showOptions: false,
      selectedOption
    })
  }

  renderOptions () {
    const { options } = this.state

    const renderedOptions = options.length
      ? options.map(o => <li key={o.id} onMouseDown={() => this.onOptionSelect(o)}>{o.name}</li>)
      : <li className='Disabled'>No results found</li>

    return <ul className='OptList'>{renderedOptions}</ul>
  }

  render () {
    const { searchTerm, showOptions, selectedOption } = this.state
    const { label, formId, formName, hint } = this.props

    return (
      <div className='SearchableSelect'>
        <label htmlFor={formId}>{label}</label>
        <input id={formId} name={formName} className='HiddenForm' value={selectedOption.id} readOnly />
        <TextInput
          aria-label={formName}
          placeholder='Select one...'
          value={searchTerm}
          onChange={this.onTextChange}
          onFocus={this.onFocus}
          onBlur={this.onBlur}
        />
        {showOptions && this.renderOptions()}
        {hint && <p className="inline-hints">{hint}</p>}
      </div>
    )
  }
}

export { SearchableSelect }
