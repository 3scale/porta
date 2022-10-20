import { SignupPageWrapper } from 'LoginPage/SignupPageWrapper'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'LoginPage/SignupPageWrapper'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'
  const PFLoginPageContainer = document.getElementById(containerId)

  if (!PFLoginPageContainer) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  if (oldLoginWrapper?.parentNode) {
    oldLoginWrapper.parentNode.removeChild(oldLoginWrapper)
  }

  const signupPageProps = safeFromJsonString<Props>(PFLoginPageContainer.dataset.signupProps) as Props
  SignupPageWrapper(signupPageProps, 'pf-login-page-container')
})
