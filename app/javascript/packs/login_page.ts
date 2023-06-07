import { safeFromJsonString } from 'utilities/json-utils'
import { LoginPageWrapper } from 'Login/components/LoginPage'

import type { Props } from 'Login/components/LoginPage'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME
  const loginPageProps = safeFromJsonString<Props>(container.dataset.loginProps)!
  LoginPageWrapper(loginPageProps, containerId)
})
