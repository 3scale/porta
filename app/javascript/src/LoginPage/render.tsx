import { lazy, StrictMode, Suspense } from 'react'
import { render } from 'react-dom'

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

  render((
    <StrictMode>
      <Suspense fallback="">
        {/* eslint-disable react/jsx-props-no-spreading */}
        {loginProps && <LoginPage {...JSON.parse(loginProps)} />}
        {changePasswordProps && <ChangePassword {...JSON.parse(changePasswordProps)} />}
        {signupProps && <SignupPage {...JSON.parse(signupProps)} />}
        {requestProps && <RequestPassword {...JSON.parse(requestProps)} />}
        {/* eslint-enable react/jsx-props-no-spreading */}
      </Suspense>
    </StrictMode>
  ), container)
}
