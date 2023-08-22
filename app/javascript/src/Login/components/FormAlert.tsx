import { Alert } from '@patternfly/react-core'

import type { AlertProps } from '@patternfly/react-core'
import type { FlashMessage } from 'Types/FlashMessages'
import type { FunctionComponent } from 'react'

interface Props {
  error?: FlashMessage;
}

const LoginAlert: FunctionComponent<Props> = ({ error }) => {
  function variant (type?: FlashMessage['type']): AlertProps['variant'] {
    switch (type) {
      case 'error':
        return 'danger'
      case 'notice':
        return 'info'
      default:
        return 'default'
    }
  }

  return (
    <Alert
      isInline
      className={error ? '' : 'invisible'}
      title={error?.message}
      variant={variant(error?.type)}
    />
  )
}

export { LoginAlert }
