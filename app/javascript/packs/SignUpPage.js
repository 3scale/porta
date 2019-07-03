import {SignupPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const loginLayout = document.querySelector('.login-layout')
  loginLayout.removeChild(document.getElementById('old-signup-page-wrapper'))

  const SignupPageContainer = document.getElementById('signup-page-container')
  const SignupPageProps = safeFromJsonString(SignupPageContainer.dataset.props)
  SignupPageWrapper(SignupPageProps, 'signup-page-container')
})
