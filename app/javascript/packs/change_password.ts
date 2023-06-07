import { ChangePasswordWrapper } from 'Login/components/ChangePasswordPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Login/components/ChangePasswordPage'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'
  const changePasswordContainer = document.getElementById(containerId)

  if (!changePasswordContainer) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { lostPasswordToken, url, errors } = safeFromJsonString<Props>(changePasswordContainer.dataset.changePasswordProps) ?? {}

  ChangePasswordWrapper({
    lostPasswordToken,
    url,
    errors
  }, 'pf-login-page-container')
})
