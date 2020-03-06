// @flow

import React from 'react'
import type { Node } from 'react'
import {createReactWrapper} from 'utilities/createReactWrapper'
import 'url-polyfill'

import {
  LoginPage
} from '@patternfly/react-core'

import {
  ForgotCredentials,
  Login3scaleForm,
  AuthenticationProviders,
  FlashMessages
} from 'LoginPage'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type FlashMessage = {
  type: string,
  message: string
}

type Props = {
  enforceSSO: boolean,
  authenticationProviders: Array<mixed>,
  flashMessages: Array<FlashMessage>,
  providerAdminDashboardPath: string,
  providerLoginPath: string,
  providerSessionsPath: string,
  providerRequestPasswordResetPath: string,
  redirectUrl: string,
  show3scaleLoginForm: boolean,
  disablePasswordReset: boolean,
  session: {
    username: ?string
  }
}

type State = {
  loginTitle: string
}

class SimpleLoginPage extends React.Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = {
      formMode: 'login',
      loginTitle: 'Log in to your account'
    }
  }

  showForgotCredentials () {
    const showForgotCredentials = !this.props.disablePasswordReset
    return showForgotCredentials && <ForgotCredentials requestPasswordResetPath={this.props.providerRequestPasswordResetPath}/>
  }

  loginForm () {
    const hasAuthenticationProviders = this.props.authenticationProviders
    const enforceSSO = this.props.enforceSSO
    return (
      <React.Fragment>
        { !enforceSSO &&
            <Login3scaleForm
              providerSessionsPath={this.props.providerSessionsPath}
              session={this.props.session}
            />
        }
        { hasAuthenticationProviders &&
          <div className='providers-separator'>
            <AuthenticationProviders
              authenticationProviders={this.props.authenticationProviders}
            />
          </div>
        }
      </React.Fragment>
    )
  }

  render (): Node {
    return (
      <LoginPage
        brandImgSrc={brandImg}
        brandImgAlt='Red Hat 3scale API Management'
        backgroundImgSrc={PF4DownstreamBG}
        backgroundImgAlt='Red Hat 3scale API Management'
        loginTitle={this.state.loginTitle}
        forgotCredentials={this.showForgotCredentials()}
        footer={null}
      >
        {
          this.props.flashMessages &&
          <FlashMessages flashMessages={this.props.flashMessages}/>
        }
        { this.loginForm() }
      </LoginPage>
    )
  }
}

const LoginPageWrapper = (props: Props, containerId: string) =>
  createReactWrapper(<SimpleLoginPage {...props} />, containerId)

export {SimpleLoginPage, LoginPageWrapper}
