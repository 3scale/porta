import React, { useState } from 'react'
import 'ActiveDocs/customize/customizeOAS.scss'

const AUTOCOMPLETE_PARAMS_MAP = {
  'app_key': 'app_keys',
  'app_id': 'app_ids',
  'application_id': 'application_ids',
  'user_key': 'user_keys',
  'user_id': 'user_ids',
  'account_id': 'account_ids',
  'metric_name': 'metric_names',
  'metric_id': 'metric_ids',
  'backend_api_metric_name': 'backend_api_metric_names',
  'service_id': 'service_ids',
  'admin_id': 'admin_ids',
  'service_plan_id': 'service_plan_ids',
  'application_plan_id': 'application_plan_ids',
  'account_plan_id': 'account_plan_ids',
  'client_id': 'client_ids'
  // TODO: secrets and tokens shouldn't autocomplete ?
  // 'client_secret': 'client_secrets',
  // 'service_token': 'service_tokens'
  // 'access_token': 'access_token',
}

const getCustomParamValue = (customParamName, accountData) => {
  const isAutocompletable = customParamName in AUTOCOMPLETE_PARAMS_MAP
  if (!isAutocompletable) {
    return undefined
  }
  const paramValue = accountData[AUTOCOMPLETE_PARAMS_MAP[customParamName]]
    .map(item => {
      return {name: item.name, value: item.value}
    })
  return paramValue.length > 0 ? paramValue : undefined
}

const AutocompleteList = ({autocomopleteValues, isOpen, customParamName, onClickAutocomplete}) => {
  return (
    <tr className={`autocomplete-row-${customParamName}`}>
      <td className="parameters-col_name"></td>
      <td className="parameters-col_description">
        <div className={`autocomplete-list autocomplete-list-${customParamName} ${isOpen ? 'show' : 'hide'}`}>
          <div className='apidocs-param-tips'>
            <ul>
              { autocomopleteValues && autocomopleteValues.map(
                (currentValue) => (
                  <li className={`autocomplete-${customParamName}`} key={currentValue.name} data-value={`${currentValue.value}`} onClick={onClickAutocomplete}>
                    <strong>{currentValue.name}</strong><br/>{currentValue.value}
                  </li>
                )
              ) }
            </ul>
          </div>
        </div>
      </td>
    </tr>
  )
}

const CustomParameterWrapper = ({customParamName, customParamValue, children}) => {
  const [isAutocompleteOpen, setIsAutocompleteOpen] = useState(false)

  const customParamInput = document.querySelector(
    `[data-param-name='${customParamName}'] .parameters-col_description input`
  )

  const handleClickAutocomplete = (e) => {
    customParamInput.value = e.currentTarget.dataset.value
    setIsAutocompleteOpen(false)
  }

  if (customParamInput) {
    customParamInput.addEventListener('focus', () => {
      setIsAutocompleteOpen(true)
    })
    document.body.addEventListener('click', (e) => {
      if (e.target === customParamInput || e.target.classList.contains(`autocomplete-${customParamName}`)) {
        return
      }
      setIsAutocompleteOpen(false)
    })
  }

  return (
    <>
      {children}
      <AutocompleteList
        customParamName={customParamName}
        autocomopleteValues={customParamValue}
        isOpen={isAutocompleteOpen}
        onClickAutocomplete={handleClickAutocomplete}
        customParamName={customParamName}
      />
    </>
  )
}

export const CustomParameterRow = (Original, system) => props => {
  const accountData = system.accountData
  const customParamName = props.rawParam._list._tail.array
    .filter(param => param[0] === 'name')[0][1]
  const customParamValue = getCustomParamValue(customParamName, accountData)

  if (!customParamName || !customParamValue) {
    return React.createElement(Original, props)
  }

  return React.createElement(
    CustomParameterWrapper,
    {customParamName, customParamValue},
    React.createElement(Original, props)
  )
}
