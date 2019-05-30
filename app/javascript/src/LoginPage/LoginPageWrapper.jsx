import React from 'react'
import {createReactWrapper} from 'utilities/createReactWrapper'
import 'url-polyfill'

import {
  LoginPage,
  BackgroundImageSrc
} from '@patternfly/react-core'

import {ForgotCredentials} from 'LoginPage/loginForm/ForgotCredentials'
import {RequestPasswordForm} from 'LoginPage/loginForm/RequestPasswordForm'
import {Login3scaleForm} from 'LoginPage/loginForm/Login3scaleForm'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale-logo.png'

import pfbg1200 from 'LoginPage/assets/images/pfbg_1200.jpg'
import pfbg768 from 'LoginPage/assets/images/pfbg_768.jpg'
import pfbg7682x from 'LoginPage/assets/images/pfbg_768@2x.jpg'
import pfbg576 from 'LoginPage/assets/images/pfbg_576.jpg'
import pfbg5762x from 'LoginPage/assets/images/pfbg_576@2x.jpg'

const images = {
  [BackgroundImageSrc.lg]: pfbg1200,
  [BackgroundImageSrc.sm]: pfbg768,
  [BackgroundImageSrc.sm2x]: pfbg7682x,
  [BackgroundImageSrc.xs]: pfbg576,
  [BackgroundImageSrc.xs2x]: pfbg5762x
}

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
        textContent='This is placeholder text only. Use this area to place any information or introductory message about your application that may be relevant to users.'
        loginTitle={this.state.loginTitle}
        forgotCredentials={
          showForgotCredentials &&
          <ForgotCredentials providerLoginPath={this.props.providerLoginPath}/>
        }
      >
        <input name='utf8' type='hidden' value='✓'/>
        {this.state.formMode === 'login' &&
          <Login3scaleForm/>
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
