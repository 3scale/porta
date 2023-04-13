import { LoginPageWrapper } from 'LoginPage/LoginPageWrapper'
import { SignupPageWrapper } from 'LoginPage/SignupPageWrapper'
import { ChangePasswordWrapper } from 'ChangePassword/components/ChangePassword'
import { RequestPasswordWrapper } from 'LoginPage/RequestPasswordWrapper'

import type { Props as RequestPasswordProps } from 'LoginPage/RequestPasswordWrapper'
import type { Props as LoginPageWrapperProps } from 'LoginPage/LoginPageWrapper'
import type { Props as SignupPageWrapperProps } from 'LoginPage/SignupPageWrapper'
import type { Props as ChangePasswordProps } from 'ChangePassword/components/ChangePassword'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-login-page-container'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { loginProps, changePasswordProps, signupProps, requestProps } = container.dataset

  if (loginProps) {
    const props = JSON.parse(loginProps) as LoginPageWrapperProps
    LoginPageWrapper(props, containerId)

  } else if (changePasswordProps) {
    const props = JSON.parse(changePasswordProps) as ChangePasswordProps
    ChangePasswordWrapper(props, containerId)

  } else if (signupProps) {
    const props = JSON.parse(signupProps) as SignupPageWrapperProps
    SignupPageWrapper(props, containerId)

  } else if (requestProps) {
    const props = JSON.parse(requestProps) as RequestPasswordProps
    RequestPasswordWrapper(props, containerId)
  }
})
