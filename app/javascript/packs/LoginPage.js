import '@babel/polyfill'
import 'core-js/es7/object'
import {LoginPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const oldLoginWrapper = document.getElementById('old-login-page-wrapper')
  oldLoginWrapper.removeChild(document.getElementById('old-login-page'))
  const loginPageContainer = document.getElementById('login-page-container')
  const loginPageProps = safeFromJsonString(loginPageContainer.dataset.loginProps)
  LoginPageWrapper(loginPageProps, 'login-page-container')
})
