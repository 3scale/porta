import { LoginPage } from '@patternfly/react-core'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'
import { FlashMessages } from 'LoginPage/loginForms/FlashMessages'
import { RequestPasswordForm } from 'LoginPage/loginForms/RequestPasswordForm'

import type { FunctionComponent } from 'react'
import type { FlashMessage } from 'Types'

interface Props {
  flashMessages?: FlashMessage[];
  providerLoginPath: string;
  providerPasswordPath: string;
}

const RequestPassword: FunctionComponent<Props> = ({
  flashMessages,
  providerLoginPath,
  providerPasswordPath
}) => (
  <LoginPage
    backgroundImgAlt="Red Hat 3scale API Management"
    backgroundImgSrc={PF4DownstreamBG}
    brandImgAlt="Red Hat 3scale API Management"
    brandImgSrc={brandImg}
    loginTitle="Request Password"
  >
    {flashMessages && <FlashMessages flashMessages={flashMessages} />}
    <RequestPasswordForm
      providerLoginPath={providerLoginPath}
      providerPasswordPath={providerPasswordPath}
    />
  </LoginPage>
)

export type { Props }
export default RequestPassword
export { RequestPassword }
