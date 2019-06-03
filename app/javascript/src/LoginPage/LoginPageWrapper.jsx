import React from 'react'
import {createReactWrapper} from 'utilities/createReactWrapper'
import 'url-polyfill'

import {
  LoginPage,
  BackgroundImageSrc
} from '@patternfly/react-core'

import {
  ForgotCredentials,
  Login3scaleForm,
  RequestPasswordForm
} from 'LoginPage'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'

import pfbg1200 from 'LoginPage/assets/images/pf4BG/pfbg_1200.png'
import pfbg768 from 'LoginPage/assets/images/pf4BG/pfbg_768.png'
import pfbg768x2 from 'LoginPage/assets/images/pf4BG/pfbg_768x2.png'
import pfbg576 from 'LoginPage/assets/images/pf4BG/pfbg_576.png'
import pfbg576x2 from 'LoginPage/assets/images/pf4BG/pfbg_576x2.png'

const images = {
  [BackgroundImageSrc.lg]: pfbg1200,
  [BackgroundImageSrc.sm]: pfbg768,
  [BackgroundImageSrc.sm2x]: pfbg768x2,
  [BackgroundImageSrc.xs]: pfbg576,
  [BackgroundImageSrc.xs2x]: pfbg576x2,
  [BackgroundImageSrc.filter]: ''
}

// import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

class SimpleLoginPage extends React.Component {
  constructor (props) {
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

  render () {
    const showForgotCredentials = this.state.formMode === 'login'
    return (
      <LoginPage
        footerListVariants='inline'
        brandImgSrc={brandImg}
        brandImgAlt='Red Hat 3scale API Management'
        backgroundImgSrc={images}
        backgroundImgAlt='Red Hat 3scale API Management'
        loginTitle={this.state.loginTitle}
        forgotCredentials={
          showForgotCredentials &&
          <ForgotCredentials providerLoginPath={this.props.providerLoginPath}/>
        }
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

const LoginPageWrapper = (props, containerId) =>
  createReactWrapper(<SimpleLoginPage {...props} />, containerId)

export {SimpleLoginPage, LoginPageWrapper}
