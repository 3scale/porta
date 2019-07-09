import '@babel/polyfill'
import 'core-js/es7/object'

import {SignupPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

const isIE11 = !!navigator.userAgent.match(/Trident\/7\./)
if (isIE11) {
  import('LoginPage/assets/styles/ie11-pf4BaseStyles.css')
}

document.addEventListener('DOMContentLoaded', () => {
  const loginPageContainer = document.getElementById('login-page-container')
  if (isIE11) {
    loginPageContainer.classList.add('isIe11', 'pf-c-page')
  }

  let oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  if (oldLoginWrapper.parentNode) {
    oldLoginWrapper.parentNode.removeChild(oldLoginWrapper)
  }

  const signupPageProps = safeFromJsonString(loginPageContainer.dataset.signupProps)
  SignupPageWrapper(signupPageProps, 'login-page-container')
})
