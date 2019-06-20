import '@babel/polyfill'
import 'core-js/es7/object'

const isIE11 = !!navigator.userAgent.match(/Trident\/7\./)
if (isIE11) {
    import('LoginPage/assets/styles/ie11-pf4BaseStyles.css')
}

import {LoginPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  oldLoginWrapper.removeChild(document.getElementById('old-login-page'))
  const loginPageContainer = document.getElementById('login-page-container')
  if (isIE11) {
    loginPageContainer.classList.add('isIe11', 'pf-c-page')
  }
  const loginPageProps = safeFromJsonString(loginPageContainer.dataset.loginProps)
  LoginPageWrapper(loginPageProps, 'login-page-container')
})
