import { ChangePasswordWrapper } from 'ChangePassword/components/ChangePassword'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'ChangePassword/components/ChangePassword'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'
  const changePasswordContainer = document.getElementById(containerId)

  if (!changePasswordContainer) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { lostPasswordToken = null, url = '', errors = [] } = safeFromJsonString<Props>(changePasswordContainer.dataset.changePasswordProps) as Props

  ChangePasswordWrapper({
    lostPasswordToken,
    url,
    errors
  }, 'pf-login-page-container')
})
