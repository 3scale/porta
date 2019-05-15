import React from 'react'
import brandImg from 'SimpleLoginPage/3scale-logo.png'
import BGImage from 'SimpleLoginPage/pfbg_1200.jpg'
import {
  LoginFooterItem,
  LoginForm,
  LoginMainFooterBandItem,
  LoginPage,
  ListItem
} from '@patternfly/react-core'
import {ExclamationCircleIcon} from '@patternfly/react-icons'

/**
 * Note: When using background-filter.svg, you must also include #image_overlay as the fragment identifier
 */

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
    this.setState({usernameValue: value})
  }

  handlePasswordChange = passwordValue => {
    this.setState({passwordValue})
  }

  onRememberMeClick = () => {
    this.setState({
      isRememberMeChecked: !this.state.isRememberMeChecked
    })
  }

  onLoginButtonClick = event => {
    event.preventDefault()
    this.setState({
      isValidUsername: !!this.state.usernameValue
    })
    this.setState({
      isValidPassword: !!this.state.passwordValue
    })
    this.setState({
      showHelperText: !this.state.usernameValue || !this.state.passwordValue
    })
  }

  render () {
    const helperText = (<React.Fragment><ExclamationCircleIcon/>&nbsp;Invalid login credentials.</React.Fragment>)

    const signUpForAccountMessage = (<LoginMainFooterBandItem>Need an account?<a href="#">Sign up.</a></LoginMainFooterBandItem>)
    const forgotCredentials = (<LoginMainFooterBandItem><a href="#">Forgot username or password?</a></LoginMainFooterBandItem>)

    const listItem = (<React.Fragment>
      <ListItem>
        <LoginFooterItem href="#">Terms of Use
        </LoginFooterItem>
      </ListItem>
    </React.Fragment>)

    const loginForm = (<LoginForm showHelperText={this.state.showHelperText} helperText={helperText} usernameLabel="Username" usernameValue={this.state.usernameValue} onChangeUsername={this.handleUsernameChange} isValidUsername={this.state.isValidUsername} passwordLabel="Password" passwordValue={this.state.passwordValue} onChangePassword={this.handlePasswordChange} isValidPassword={this.state.isValidPassword} rememberMeLabel="Keep me logged in for 30 days." isRememberMeChecked={this.state.isRememberMeChecked} onChangeRememberMe={this.onRememberMeClick} rememberMeAriaLabel="Remember me Checkbox" onLoginButtonClick={this.onLoginButtonClick}/>)

    return (<LoginPage footerListVariants="inline" brandImgSrc={brandImg} brandImgAlt="PatternFly logo" backgroundImgSrc={BGImage} backgroundImgAlt="Images" footerListItems={listItem} textContent="This is placeholder text only." loginTitle="Log in to your account" signUpForAccountMessage={signUpForAccountMessage} forgotCredentials={forgotCredentials}>
      {loginForm}
    </LoginPage>)
  }
}

export default SimpleLoginPage
