import { ExpirationDatePickerWrapper } from 'AccessTokens/components/ExpirationDatePicker'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'AccessTokens/components/ExpirationDatePicker'

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
