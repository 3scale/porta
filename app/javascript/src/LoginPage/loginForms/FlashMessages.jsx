// @flow

import * as React from 'react'
import { ExclamationCircleIcon } from '@patternfly/react-icons'
import type { FlashMessage } from 'Types'

const FlashMessages = ({ flashMessages }: {flashMessages: Array<FlashMessage>}): React.Node => {
  const messagesList = flashMessages.map(message =>
    <p key={message.message}
      className={`pf-c-form__helper-text pf-m-${message.type}`}
    >
      <ExclamationCircleIcon />
      {` ${message.message}`}
    </p>
  )
  return (
    <div>
      {messagesList}
    </div>
  )
}

export { FlashMessages }
