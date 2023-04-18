import { Component } from 'react'
import { LoginPage } from '@patternfly/react-core'

import { AuthenticationProviders } from 'LoginPage/loginForms/AuthenticationProviders'
import { FlashMessages } from 'LoginPage/loginForms/FlashMessages'
import { ForgotCredentials } from 'LoginPage/loginForms/ForgotCredentials'
import { Login3scaleForm } from 'LoginPage/loginForms/Login3scaleForm'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

import type { ReactNode } from 'react'
import type { ProvidersProps } from 'LoginPage/loginForms/AuthenticationProviders'
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

interface State {
  loginTitle: string;
}

// eslint-disable-next-line react/require-optimization -- TODO: make this a function component
class SimpleLoginPage extends Component<Props, State> {
  public constructor (props: Props) {
    super(props)
    this.state = {
      loginTitle: 'Log in to your account'
    }
  }

  private showForgotCredentials () {
    const { disablePasswordReset, providerRequestPasswordResetPath, show3scaleLoginForm } = this.props
    const showResetPasswordLink = show3scaleLoginForm && !disablePasswordReset
    return showResetPasswordLink && <ForgotCredentials requestPasswordResetPath={providerRequestPasswordResetPath} />
  }

  private loginForm () {
    const hasAuthenticationProviders = this.props.authenticationProviders
    const show3scaleLoginForm = this.props.show3scaleLoginForm
    return (
      <>
        {show3scaleLoginForm && (
          <Login3scaleForm
            providerSessionsPath={this.props.providerSessionsPath}
            session={this.props.session}
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

  // eslint-disable-next-line @typescript-eslint/member-ordering
  public render (): ReactNode {
    return (
      <LoginPage
        backgroundImgAlt="Red Hat 3scale API Management"
        backgroundImgSrc={PF4DownstreamBG}
        brandImgAlt="Red Hat 3scale API Management"
        brandImgSrc={brandImg}
        forgotCredentials={this.showForgotCredentials()}
        loginTitle={this.state.loginTitle}
      >
        {this.props.flashMessages && <FlashMessages flashMessages={this.props.flashMessages} />}
        {this.loginForm()}
      </LoginPage>
    )
  }
}

export type { Props }
export { SimpleLoginPage as default }
