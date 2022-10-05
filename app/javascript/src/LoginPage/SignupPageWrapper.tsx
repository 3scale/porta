import { createReactWrapper } from 'utilities/createReactWrapper'
import { LoginPage } from '@patternfly/react-core'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'
import 'LoginPage/assets/styles/loginPage.scss'
import { FlashMessages } from 'LoginPage/loginForms/FlashMessages'
import { SignupForm } from 'LoginPage/loginForms/SignupForm'

import type { FunctionComponent } from 'react'
import type { SignupProps as Props } from 'Types'

const SignupPage: FunctionComponent<Props> = ({ user, name, path }) => (
  <LoginPage
    backgroundImgAlt="Red Hat 3scale API Management"
    backgroundImgSrc={PF4DownstreamBG}
    brandImgAlt="Red Hat 3scale API Management"
    brandImgSrc={brandImg}
    loginTitle={`Signup to ${String(name)}`}
    // footer={null}
  >
    {user.errors && <FlashMessages flashMessages={user.errors} />}
    <SignupForm path={path} user={user} />
  </LoginPage>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const SignupPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<SignupPage {...props} />, containerId)

export { SignupPage, SignupPageWrapper, Props }
