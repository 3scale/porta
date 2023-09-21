import { LoginMainFooterBandItem, LoginPage as PF4LoginPage } from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { AuthenticationProviders } from 'Login/components/AuthenticationProviders'
import { LoginForm } from 'Login/components/LoginForm'
import brandImg from 'Login/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'Login/assets/images/PF4DownstreamBG.svg'

import type { FunctionComponent } from 'react'
import type { ProvidersProps } from 'Login/components/AuthenticationProviders'
import type { FlashMessage } from 'Types'

interface Props {
  authenticationProviders: ProvidersProps[];
  flashMessages: FlashMessage[];
  providerSessionsPath: string;
  providerRequestPasswordResetPath: string;
  show3scaleLoginForm: boolean;
  disablePasswordReset: boolean;
  session: {
    username: string | null;
  };
}

const LoginPage: FunctionComponent<Props> = ({
  authenticationProviders,
  disablePasswordReset,
  flashMessages,
  providerRequestPasswordResetPath,
  providerSessionsPath,
  session,
  show3scaleLoginForm
}) => (
  <PF4LoginPage
    backgroundImgAlt="Red Hat 3scale API Management"
    backgroundImgSrc={PF4DownstreamBG}
    brandImgAlt="Red Hat 3scale API Management"
    brandImgSrc={brandImg}
    forgotCredentials={show3scaleLoginForm && !disablePasswordReset && (
      <LoginMainFooterBandItem>
        <a
          href={providerRequestPasswordResetPath}
          // HACK: prevent click from missing link after input loses focus and component re-renders
          onMouseDown={(event) => { event.currentTarget.click() }}
        >
          Forgot password?
        </a>
      </LoginMainFooterBandItem>
    )}
    loginTitle="Log in to your account"
  >
    {show3scaleLoginForm && (
      <LoginForm
        error={flashMessages.length ? flashMessages[0] : undefined}
        providerSessionsPath={providerSessionsPath}
        session={session}
      />
    )}
    {authenticationProviders.length > 0 && (
      <div className="providers-separator">
        <AuthenticationProviders authenticationProviders={authenticationProviders} />
      </div>
    )}
  </PF4LoginPage>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const LoginPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<LoginPage {...props} />, containerId) }

export type { Props }
export { LoginPage, LoginPageWrapper }
