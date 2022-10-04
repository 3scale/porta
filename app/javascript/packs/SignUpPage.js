import '@babel/polyfill'
import 'core-js/es7/object'
import { SignupPageWrapper } from 'LoginPage'
import { safeFromJsonString } from 'utilities'

document.addEventListener('DOMContentLoaded', () => {
  const PFLoginPageContainer = document.getElementById('pf-login-page-container')

  let oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  if (oldLoginWrapper.parentNode) {
    oldLoginWrapper.parentNode.removeChild(oldLoginWrapper)
  }

  const signupPageProps = safeFromJsonString(PFLoginPageContainer.dataset.signupProps)
  SignupPageWrapper(signupPageProps, 'pf-login-page-container')
})
