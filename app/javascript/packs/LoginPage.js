import '@babel/polyfill'
import 'core-js/es7/object'
import { safeFromJsonString, isBrowserIE11 } from 'utilities'

import { LoginPageWrapper } from 'LoginPage'

const isIE11 = isBrowserIE11(window)
if (isIE11) {
  // eslint-disable-next-line no-unused-expressions
  import('LoginPage/assets/styles/ie11-pf4BaseStyles.css')
}

document.addEventListener('DOMContentLoaded', () => {
  const oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  oldLoginWrapper.removeChild(document.getElementById('old-login-page'))
  const PFLoginPageContainer = document.getElementById('pf-login-page-container')
  if (isIE11) {
    PFLoginPageContainer.classList.add('isIe11', 'pf-c-page')
  }
  const loginPageProps = safeFromJsonString(PFLoginPageContainer.dataset.loginProps)
  LoginPageWrapper(loginPageProps, 'pf-login-page-container')
})
