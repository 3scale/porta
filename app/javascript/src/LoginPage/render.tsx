/* eslint-disable react/jsx-props-no-spreading */
import { lazy, StrictMode, Suspense } from 'react'
import { render } from 'react-dom'

import type { ReactNode } from 'react'
import type { Props as RequestPasswordProps } from 'LoginPage/RequestPasswordWrapper'
import type { Props as LoginPageWrapperProps } from 'LoginPage/LoginPageWrapper'
import type { Props as SignupPageWrapperProps } from 'LoginPage/SignupPageWrapper'
import type { Props as ChangePasswordProps } from 'ChangePassword/components/ChangePassword'

/* eslint-disable @typescript-eslint/no-unsafe-return */
// @ts-expect-error TS2691
const LoginPage = lazy(() => import('LoginPage/LoginPageWrapper.tsx'))
// @ts-expect-error TS2691
const RequestPassword = lazy(() => import('LoginPage/RequestPasswordWrapper.tsx'))
// @ts-expect-error TS2691
const SignupPage = lazy(() => import('LoginPage/SignupPageWrapper.tsx'))
// @ts-expect-error TS2691
const ChangePassword = lazy(() => import('ChangePassword/components/ChangePassword.tsx'))
/* eslint-enable @typescript-eslint/no-unsafe-return */

export default function (container: HTMLElement): void {
  const { loginProps, changePasswordProps, signupProps, requestProps } = container.dataset
  let component: ReactNode = undefined

  if (loginProps) {
    const props = JSON.parse(loginProps) as LoginPageWrapperProps
    component = <LoginPage {...props} />

  } else if (changePasswordProps) {
    const props = JSON.parse(changePasswordProps) as ChangePasswordProps
    component = <ChangePassword {...props} />

  } else if (signupProps) {
    const props = JSON.parse(signupProps) as SignupPageWrapperProps
    component = <SignupPage {...props} />

  } else if (requestProps) {
    const props = JSON.parse(requestProps) as RequestPasswordProps
    component = <RequestPassword {...props} />
  }

  if (!component) {
    return
  }

  render((
    <StrictMode>
      <Suspense fallback="">
        {loginProps && <LoginPage {...JSON.parse(loginProps)} />}
        {changePasswordProps && <ChangePassword {...JSON.parse(changePasswordProps)} />}
        {signupProps && <SignupPage {...JSON.parse(signupProps)} />}
        {requestProps && <RequestPassword {...JSON.parse(requestProps)} />}
      </Suspense>
    </StrictMode>)
  , container)
}
