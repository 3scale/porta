import '@babel/polyfill'
import 'core-js/es7/object'

import {LoginPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  oldLoginWrapper.removeChild(document.getElementById('old-login-page'))
  const PFLoginPageContainer = document.getElementById('pf-login-page-container')
  const loginPageProps = safeFromJsonString(PFLoginPageContainer.dataset.loginProps)
  LoginPageWrapper(loginPageProps, 'pf-login-page-container')
})
