import { LoginPage } from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import brandImg from 'Login/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'Login/assets/images/PF4DownstreamBG.svg'
import { RequestPasswordForm } from 'Login/components/RequestPasswordForm'

import type { FunctionComponent } from 'react'
import type { FlashMessage } from 'Types'

interface Props {
  flashMessages: FlashMessage[];
  providerLoginPath: string;
  providerPasswordPath: string;
}

const RequestPasswordPage: FunctionComponent<Props> = ({
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
    <RequestPasswordForm
      flashMessages={flashMessages}
      providerLoginPath={providerLoginPath}
      providerPasswordPath={providerPasswordPath}
    />
  </LoginPage>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const RequestPasswordWrapper = (props: Props, containerId: string): void => { createReactWrapper(<RequestPasswordPage {...props} />, containerId) }

export type { Props }
export { RequestPasswordPage, RequestPasswordWrapper }
