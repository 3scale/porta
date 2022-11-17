import { LoginMainFooterBandItem } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  requestPasswordResetPath: string;
}

const ForgotCredentials: FunctionComponent<Props> = ({ requestPasswordResetPath }) => (
  <LoginMainFooterBandItem>
    <a href={requestPasswordResetPath}>Forgot password?</a>
  </LoginMainFooterBandItem>
)

export { ForgotCredentials, Props }
