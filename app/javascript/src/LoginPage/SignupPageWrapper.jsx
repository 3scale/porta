// @flow

import React from 'react'
import {createReactWrapper} from 'utilities/createReactWrapper'

import {LoginPage} from '@patternfly/react-core'
import {SignupForm} from 'LoginPage'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

type Props = {
  email: string,
  name: string,
  path: string
}

const SignupPage = ({email, name, path}: Props) => (
  <LoginPage
    brandImgSrc={brandImg}
    brandImgAlt='Red Hat 3scale API Management'
    backgroundImgSrc={PF4DownstreamBG}
    backgroundImgAlt='Red Hat 3scale API Management'
    loginTitle={`Signup to ${name}`}
    footer={null}
  >
    <SignupForm path={path} email={email}/>
  </LoginPage>
)

const SignupPageWrapper = (props: Props, containerId: string) =>
  createReactWrapper(<SignupPage {...props} />, containerId)

export {SignupPage, SignupPageWrapper}
