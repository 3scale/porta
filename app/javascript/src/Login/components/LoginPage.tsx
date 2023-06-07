import { LoginPage } from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { AuthenticationProviders } from 'Login/components/AuthenticationProviders'
import { FlashMessages } from 'Login/components/FlashMessages'
import { ForgotCredentials } from 'Login/components/ForgotCredentials'
import { Login3scaleForm } from 'Login/components/Login3scaleForm'
import brandImg from 'Login/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'Login/assets/images/PF4DownstreamBG.svg'

import type { FunctionComponent } from 'react'
import type { ProvidersProps } from 'Login/components/AuthenticationProviders'
import type { FlashMessage } from 'Types'

interface Props {
  authenticationProviders?: ProvidersProps[];
  flashMessages?: FlashMessage[];
  providerSessionsPath: string;
  providerRequestPasswordResetPath: string;
  show3scaleLoginForm: boolean;
  disablePasswordReset: boolean;
  session: {
    username: string | null | undefined;
  };
}

const SimpleLoginPage: FunctionComponent<Props> = (props) => {
  function showForgotCredentials () {
    const { disablePasswordReset, providerRequestPasswordResetPath, show3scaleLoginForm } = props
    const showResetPasswordLink = show3scaleLoginForm && !disablePasswordReset
    return showResetPasswordLink && <ForgotCredentials requestPasswordResetPath={providerRequestPasswordResetPath} />
  }

  function loginForm () {
    const hasAuthenticationProviders = props.authenticationProviders
    const show3scaleLoginForm = props.show3scaleLoginForm
    return (
      <>
        {show3scaleLoginForm && (
          <Login3scaleForm
            providerSessionsPath={props.providerSessionsPath}
            session={props.session}
          />
        )}
        {hasAuthenticationProviders && (
          <div className="providers-separator">
            <AuthenticationProviders
              authenticationProviders={hasAuthenticationProviders}
            />
          </div>
        )}
      </>
    )
  }

  return (
    <LoginPage
      backgroundImgAlt="Red Hat 3scale API Management"
      backgroundImgSrc={PF4DownstreamBG}
      brandImgAlt="Red Hat 3scale API Management"
      brandImgSrc={brandImg}
      forgotCredentials={showForgotCredentials()}
      loginTitle="Log in to your account"
    >
      {props.flashMessages && <FlashMessages flashMessages={props.flashMessages} />}
      {loginForm()}
    </LoginPage>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const LoginPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<SimpleLoginPage {...props} />, containerId) }

export type { Props }
export { SimpleLoginPage, LoginPageWrapper }
