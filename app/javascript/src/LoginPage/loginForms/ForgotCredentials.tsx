import * as React from 'react'
import { LoginMainFooterBandItem } from '@patternfly/react-core'

const ForgotCredentials = (
  {
    requestPasswordResetPath
  }: {
    requestPasswordResetPath: string
  }
): React.ReactElement => <LoginMainFooterBandItem>
  <a href={requestPasswordResetPath}>Forgot password?</a>
</LoginMainFooterBandItem>

export { ForgotCredentials }
