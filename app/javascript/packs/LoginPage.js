import {LoginPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const loginPageContainer = document.getElementById('login-page-wrapper')
  const loginPageProps = safeFromJsonString(loginPageContainer.dataset.loginProps)
  LoginPageWrapper(loginPageProps, 'login-page-wrapper')
})
