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
  RequestPasswordForm
} from 'LoginPage'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type Props = {
  authenticationProviders: string,
  providerAdminDashboardPath: string,
  providerLoginPath: string,
  providerPasswordPath: string,
  providerSessionsPath: string,
  redirectUrl: string,
  show3scaleLoginForm: boolean
}

type State = {
  formMode: string,
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

  getURL () {
    try {
      const url = new URL(window.location.href)
      const formMode = url.search === '?request_password_reset=true' ? 'password-reset' : 'login'
      const loginTitle = formMode === 'login' ? 'Log in to your account' : 'Request a password reset link by email'
      this.setState({formMode, loginTitle})
    } catch (e) {
      console.error(e)
    }
  }

  componentDidMount () {
    this.getURL()
  }

  showForgotCredentials () {
    const showForgotCredentials = this.state.formMode === 'login'
    return showForgotCredentials && <ForgotCredentials providerLoginPath={this.props.providerLoginPath}/>
  }

  render (): Node {
    return (
      <LoginPage
        footerListVariants='inline'
        brandImgSrc={brandImg}
        brandImgAlt='Red Hat 3scale API Management'
        backgroundImgSrc={PF4DownstreamBG}
        backgroundImgAlt='Red Hat 3scale API Management'
        loginTitle={this.state.loginTitle}
        forgotCredentials={this.showForgotCredentials()}
      >
        {this.state.formMode === 'login' &&
          <Login3scaleForm
            providerSessionsPath={this.props.providerSessionsPath}
          />
        }
        {this.state.formMode === 'password-reset' &&
          <RequestPasswordForm
            providerPasswordPath={this.props.providerPasswordPath}
            providerLoginPath={this.props.providerLoginPath}
          />
        }
      </LoginPage>
    )
  }
}

const LoginPageWrapper = (props: Props, containerId: string) =>
  createReactWrapper(<SimpleLoginPage {...props} />, containerId)

export {SimpleLoginPage, LoginPageWrapper}
