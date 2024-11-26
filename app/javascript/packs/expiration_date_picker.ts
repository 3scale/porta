import { ExpirationDatePickerWrapper } from 'AccessTokens/components/ExpirationDatePicker'

import type { Props } from 'AccessTokens/components/ExpirationDatePicker'

import { safeFromJsonString } from '../src/utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'expiration-date-picker-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error(`Missing container with id "${containerId}"`)
  }

  const props = safeFromJsonString<Props>(container.dataset.props)

  if (!props) {
    throw new Error('Missing props')
  }

  ExpirationDatePickerWrapper(props, containerId)
})
