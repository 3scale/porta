import { createReactWrapper } from 'utilities'

import { LoginPage } from '@patternfly/react-core'
import { SignupForm, FlashMessages } from 'LoginPage'
import type { SignupProps } from 'Types'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

const SignupPage = (
  {
    user,
    name,
    path
  }: SignupProps
): React.ReactElement => <LoginPage
  brandImgSrc={brandImg}
  brandImgAlt='Red Hat 3scale API Management'
  backgroundImgSrc={PF4DownstreamBG}
  backgroundImgAlt='Red Hat 3scale API Management'
  loginTitle={`Signup to ${String(name)}`}
  // footer={null}
>
  {user.errors && <FlashMessages flashMessages={user.errors}/>}
  <SignupForm path={path} user={user}/>
</LoginPage>

const SignupPageWrapper = (props: SignupProps, containerId: string): void => createReactWrapper(<SignupPage {...props} />, containerId)

export { SignupPage, SignupPageWrapper }
