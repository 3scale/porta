import React from 'react'
import 'ActiveDocs/customize/customizeOAS.scss'

const findParamInService = (paramName, service) => {
  return service[paramName]
}

const Select = ({value, className}) => {
  return (
    <div className={`autocomplete-select ${className}`}>
      <select>
        <option value={value}>{value}</option>
      </select>
    </div>
  )
}

export const ParameterRow = (Original, system) => props => {
  const paramList = props.rawParam._list._tail.array
  const paramName = paramList.filter(param => param[0] === 'name')[0][1]

  const customParam = findParamInService(paramName, system.service)
  if (!customParam) {
    return React.createElement(Original, props)
  }

  const input = document.querySelector(
    `[data-param-name='${paramName}'] .parameters-col_description input`
  )

  if (input) {
    input.addEventListener('focus', () => {
      console.log('Hey!!')
    })
    input.addEventListener('')
  }

  return React.createElement(
    'div',
    null,
    React.createElement(Original, props),
    <Select value={customParam} className="show" />
  )
}
