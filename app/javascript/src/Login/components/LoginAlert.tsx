import { Alert } from '@patternfly/react-core'

import type { AlertProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'

interface Props {
  type?: 'error' | 'notice' | 'success';
  message?: string;
}

const LoginAlert: FunctionComponent<Props> = ({ type = 'default', message }) => {
  const variant: Record<string, AlertProps['variant']> = {
    error: 'danger',
    notice: 'info',
    success: 'success',
    default: 'default'
  }

  return (
    <Alert
      isInline
      className={message ? '' : 'invisible'}
      // eslint-disable-next-line react/no-array-index-key
      title={message?.split('\n').map((m, i) => <p key={i}>{m}</p>)}
      variant={variant[type]}
    />
  )
}

export { LoginAlert }
