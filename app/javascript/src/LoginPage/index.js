import React from 'react'

import brandImg from 'LoginPage/3scale-logo.png'
import pfbg1200 from 'LoginPage/assets/images/pfbg_1200.jpg'
import pfbg768 from 'LoginPage/assets/images/pfbg_768.jpg'
import pfbg7682x from 'LoginPage/assets/images/pfbg_768@2x.jpg'
import pfbg576 from 'LoginPage/assets/images/pfbg_576.jpg'
import pfbg5762x from 'LoginPage/assets/images/pfbg_576@2x.jpg'

import {
  LoginFooterItem,
  LoginForm,
  LoginMainFooterBandItem,
  LoginPage,
  BackgroundImageSrc,
  ListItem
} from '@patternfly/react-core'
import { ExclamationCircleIcon } from '@patternfly/react-icons'

import 'LoginPage/assets/styles/loginPage.scss'
/**
 * Note: When using background-filter.svg, you must also include #image_overlay as the fragment identifier
 */

const images = {
  [BackgroundImageSrc.lg]: pfbg1200,
  [BackgroundImageSrc.sm]: pfbg768,
  [BackgroundImageSrc.sm2x]: pfbg7682x,
  [BackgroundImageSrc.xs]: pfbg576,
  [BackgroundImageSrc.xs2x]: pfbg5762x,
  [BackgroundImageSrc.filter]: 'none'
}

class SimpleLoginPage extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      showHelperText: false,
      usernameValue: '',
      isValidUsername: true,
      passwordValue: '',
      isValidPassword: true,
      isRememberMeChecked: false
    }
  }

  handleUsernameChange = value => {
    this.setState({ usernameValue: value })
  }

  handlePasswordChange = passwordValue => {
    this.setState({ passwordValue })
  }

  onRememberMeClick = () => {
    this.setState({ isRememberMeChecked: !this.state.isRememberMeChecked })
  }

  onLoginButtonClick = event => {
    event.preventDefault()
    this.setState({ isValidUsername: !!this.state.usernameValue })
    this.setState({ isValidPassword: !!this.state.passwordValue })
    this.setState({ showHelperText: !this.state.usernameValue || !this.state.passwordValue })
  }

  render () {
    const helperText = (
      <React.Fragment>
        <ExclamationCircleIcon />
        &nbspInvalid login credentials.
      </React.Fragment>
    )

    const forgotCredentials = (
      <LoginMainFooterBandItem>
        <a href="#">Forgot password?</a>
      </LoginMainFooterBandItem>
    )

    const listItem = (
      <React.Fragment>
        <ListItem>
          <LoginFooterItem href="#">Terms of Use </LoginFooterItem>
        </ListItem>
        <ListItem>
          <LoginFooterItem href="#">Help</LoginFooterItem>
        </ListItem>
        <ListItem>
          <LoginFooterItem href="#">Privacy Policy</LoginFooterItem>
        </ListItem>
      </React.Fragment>
    )

    const loginForm = (
      <LoginForm
        showHelperText={this.state.showHelperText}
        helperText={helperText}
        usernameLabel="Email or Username"
        usernameValue={this.state.usernameValue}
        onChangeUsername={this.handleUsernameChange}
        isValidUsername={this.state.isValidUsername}
        passwordLabel="Password"
        passwordValue={this.state.passwordValue}
        onChangePassword={this.handlePasswordChange}
        isValidPassword={this.state.isValidPassword}
        isRememberMeChecked={this.state.isRememberMeChecked}
        onChangeRememberMe={this.onRememberMeClick}
        rememberMeAriaLabel="Remember me Checkbox"
        onLoginButtonClick={this.onLoginButtonClick}
      />
    )

    return (
      <LoginPage
        footerListVariants="inline"
        brandImgSrc={brandImg}
        brandImgAlt="Red Hat 3scale API Management"
        backgroundImgSrc={images}
        backgroundImgAlt="Red Hat 3scale API Management"
        footerListItems={listItem}
        textContent="This is placeholder text only. Use this area to place any information or introductory message about your application that may be relevant to users."
        loginTitle="Log in to your account"
        forgotCredentials={forgotCredentials}
      >
        {loginForm}
      </LoginPage>
    )
  }
}

export default SimpleLoginPage
