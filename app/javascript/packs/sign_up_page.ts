import { SignupPageWrapper } from 'Login/components/SignupPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Login/components/SignupPage'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const signupPageProps = safeFromJsonString<Props>(container.dataset.signupProps)

  if (!signupPageProps) {
    throw new Error('Missing props for SignupPage')
  }

  SignupPageWrapper(signupPageProps, containerId)
})
