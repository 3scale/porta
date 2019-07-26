// @flow

import React from 'react'
import {createReactWrapper} from 'utilities/createReactWrapper'

import {LoginPage} from '@patternfly/react-core'
import {SignupForm, FlashMessages} from 'LoginPage'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type Errors = {
  [string]: string[]
}
type Props = {
  user: {
    email: string,
    firstname: string,
    lastname: string,
    username: string,
    errors: Errors
  },
  name: string,
  path: string
}

const ErrorMessages = ({errors}: {errors: Errors}) => {
  return Object.entries(errors).map(
    (error, i) => {
      const flashMessage = [{
        type: 'error',
        message: error.join(' ')
      }]
      return <FlashMessages flashMessages={flashMessage} key={error.join('')}/>
    }
  )
}

const SignupPage = ({user, name, path}: Props) => (
  <LoginPage
    brandImgSrc={brandImg}
    brandImgAlt='Red Hat 3scale API Management'
    backgroundImgSrc={PF4DownstreamBG}
    backgroundImgAlt='Red Hat 3scale API Management'
    loginTitle={`Signup to ${name}`}
    footer={null}
  >
    <ErrorMessages errors={user.errors} />
    <SignupForm path={path} user={user}/>
  </LoginPage>
)

const SignupPageWrapper = (props: Props, containerId: string) =>
  createReactWrapper(<SignupPage {...props} />, containerId)

export {SignupPage, SignupPageWrapper}
