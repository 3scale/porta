import React, { useState } from 'react'
import 'ActiveDocs/customize/customizeOAS.scss'

const findCustomParam = (customParamName, customParamsList) => {
  return customParamsList[customParamName]
}

const Select = ({optionValues, isOpen, onChangeHandler}) => {
  return (
    <tr>
      <td className="parameters-col_name"></td>
      <td className="parameters-col_description">
        <div className={`renderedMarkdown autocomplete-select ${isOpen ? 'show' : 'hide'}`}>
          <select onChange={onChangeHandler}>
            { optionValues && optionValues.map((value) => <option value={value}>{value}</option>) }
          </select>
        </div>
      </td>
    </tr>
  )
}

const CustomParameterWrapper = ({customParamName, customParamValue, children}) => {
  const [isSelectOpen, setIsSelectOpen] = useState(false)

  const customParamInput = document.querySelector(
    `[data-param-name='${customParamName}'] .parameters-col_description input`
  )

  const onChangeHandler = (e) => {
    console.log(e.target.value)
    customParamInput.value = e.target.value
    setIsSelectOpen(false)
  }

  if (customParamInput) {
    customParamInput.addEventListener('click', () => {
      setIsSelectOpen(!isSelectOpen)
    })
  }

  return (
    <>
      {children}
      <Select
        optionValues={customParamValue}
        isOpen={isSelectOpen}
        onChangeHandler={onChangeHandler}
      />
    </>
  )
}

export const CustomParameterRow = (Original, system) => props => {
  const customParamsList = system.customParamsList
  const customParamName = props.rawParam._list._tail.array
    .filter(param => param[0] === 'name')[0][1]
  const customParamValue = findCustomParam(customParamName, customParamsList)

  if (!customParamName) {
    return React.createElement(Original, props)
  }

  return React.createElement(
    CustomParameterWrapper,
    {customParamName, customParamValue},
    React.createElement(Original, props)
  )
}
