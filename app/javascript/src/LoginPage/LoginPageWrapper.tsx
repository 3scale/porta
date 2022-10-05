import 'url-polyfill'
import { Component } from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { LoginPage } from '@patternfly/react-core'
import { AuthenticationProviders } from 'LoginPage/loginForms/AuthenticationProviders'
import { FlashMessages } from 'LoginPage/loginForms/FlashMessages'
import { ForgotCredentials } from 'LoginPage/loginForms/ForgotCredentials'
import { Login3scaleForm } from 'LoginPage/loginForms/Login3scaleForm'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'
import 'LoginPage/assets/styles/loginPage.scss'

import type { ProvidersProps } from 'LoginPage/loginForms/AuthenticationProviders'
import type { FlashMessage } from 'Types'

type Props = {
  authenticationProviders: Array<ProvidersProps>,
  flashMessages?: Array<FlashMessage>,
  providerAdminDashboardPath: string,
  providerLoginPath: string,
  providerSessionsPath: string,
  providerRequestPasswordResetPath: string,
  redirectUrl: string,
  show3scaleLoginForm: boolean,
  disablePasswordReset: boolean,
  session: {
    username: string | null | undefined
  }
}

type State = {
  loginTitle: string
}

class SimpleLoginPage extends Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      loginTitle: 'Log in to your account'
    }
  }

  showForgotCredentials () {
    const { disablePasswordReset, providerRequestPasswordResetPath, show3scaleLoginForm } = this.props
    const showResetPasswordLink = show3scaleLoginForm && !disablePasswordReset
    return showResetPasswordLink && <ForgotCredentials requestPasswordResetPath={providerRequestPasswordResetPath} />
  }

  loginForm () {
    const hasAuthenticationProviders = this.props.authenticationProviders
    const show3scaleLoginForm = this.props.show3scaleLoginForm
    return (
      <>
        { show3scaleLoginForm && (
          <Login3scaleForm
            providerSessionsPath={this.props.providerSessionsPath}
            session={this.props.session}
          />
        )}
        { hasAuthenticationProviders && (
          <div className='providers-separator'>
            <AuthenticationProviders
              authenticationProviders={this.props.authenticationProviders}
            />
          </div>
        )}
      </>
    )
  }

  render () {
    return (
      <LoginPage
        backgroundImgAlt='Red Hat 3scale API Management'
        backgroundImgSrc={PF4DownstreamBG}
        brandImgAlt='Red Hat 3scale API Management'
        brandImgSrc={brandImg}
        forgotCredentials={this.showForgotCredentials()}
        loginTitle={this.state.loginTitle}
        // footer={null
      >
        { this.props.flashMessages && <FlashMessages flashMessages={this.props.flashMessages} /> }
        { this.loginForm() }
      </LoginPage>
    )
  }
}

// eslint-disable-next-line react/jsx-props-no-spreading
const LoginPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<SimpleLoginPage {...props} />, containerId)

export { SimpleLoginPage, LoginPageWrapper, Props }
