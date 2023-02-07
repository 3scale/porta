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

  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME
  const loginPageProps = safeFromJsonString<Props>(container.dataset.loginProps)!
  LoginPageWrapper(loginPageProps, containerId)
})
