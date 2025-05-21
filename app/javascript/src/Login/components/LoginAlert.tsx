import { Alert } from '@patternfly/react-core'

import type { IAlert } from 'Types'
import type { FunctionComponent } from 'react'

type Props = IAlert

const LoginAlert: FunctionComponent<Props> = ({ type = 'default', message }) => {
  return (
    <Alert
      isInline
      className={message ? '' : 'invisible'}
      // eslint-disable-next-line react/no-array-index-key
      title={message?.split('\n').map((m, i) => <p key={i}>{m}</p>)}
      variant={type}
    />
  )
}

export { LoginAlert }
