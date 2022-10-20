import { safeFromJsonString } from 'utilities/json-utils'
import { LoginPageWrapper } from 'LoginPage/LoginPageWrapper'

import type { Props } from 'LoginPage/LoginPageWrapper'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'

  const oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  const oldLoginPage = document.getElementById('old-login-page')
  if (oldLoginWrapper && oldLoginPage ) {
    oldLoginWrapper.removeChild(oldLoginPage)
  }

  const PFLoginPageContainer = document.getElementById(containerId)

  if (!PFLoginPageContainer) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const loginPageProps = safeFromJsonString<Props>(PFLoginPageContainer.dataset.loginProps) as Props
  LoginPageWrapper(loginPageProps, containerId)
})
