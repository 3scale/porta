import * as React from 'react';
import { createReactWrapper } from 'utilities'

import { LoginPage } from '@patternfly/react-core'
import { RequestPasswordForm, FlashMessages } from 'LoginPage'

import 'LoginPage/assets/styles/loginPage.scss'

import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

import type { FlashMessage } from 'Types'

type Props = {
  flashMessages: Array<FlashMessage>,
  providerLoginPath: string,
  providerPasswordPath: string
};

const RequestPassword = (
  {
    flashMessages,
    providerLoginPath,
    providerPasswordPath,
  }: Props,
): React.ReactElement => <LoginPage
  brandImgSrc={brandImg}
  brandImgAlt='Red Hat 3scale API Management'
  backgroundImgSrc={PF4DownstreamBG}
  backgroundImgAlt='Red Hat 3scale API Management'
  loginTitle='Request Password'
>
  {flashMessages && <FlashMessages flashMessages={flashMessages}/>}
  <RequestPasswordForm
    providerLoginPath={providerLoginPath}
    providerPasswordPath={providerPasswordPath}
  />
</LoginPage>

const RequestPasswordWrapper = (props: Props, containerId: string): void => createReactWrapper(<RequestPassword {...props} />, containerId)

export { RequestPassword, RequestPasswordWrapper }
