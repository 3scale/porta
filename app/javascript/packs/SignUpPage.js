import '@babel/polyfill'
import 'core-js/es7/object'

import {SignupPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

const isIE11 = !!navigator.userAgent.match(/Trident\/7\./)
if (isIE11) {
  import('LoginPage/assets/styles/ie11-pf4BaseStyles.css')
}

document.addEventListener('DOMContentLoaded', () => {
  const signupPageContainer = document.getElementById('signup-page-container')
  if (isIE11) {
    signupPageContainer.classList.add('isIe11', 'pf-c-page')
  }

  const loginLayout = document.querySelector('.login-layout')
  loginLayout.removeChild(document.getElementById('old-signup-page-wrapper'))

  const signupPageProps = safeFromJsonString(signupPageContainer.dataset.props)
  SignupPageWrapper(signupPageProps, 'signup-page-container')
})
