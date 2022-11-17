import { SignupPageWrapper } from 'LoginPage/SignupPageWrapper'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'LoginPage/SignupPageWrapper'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  if (oldLoginWrapper?.parentNode) {
    oldLoginWrapper.parentNode.removeChild(oldLoginWrapper)
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME
  const signupPageProps = safeFromJsonString<Props>(container.dataset.signupProps)!
  SignupPageWrapper(signupPageProps, 'pf-login-page-container')
})
