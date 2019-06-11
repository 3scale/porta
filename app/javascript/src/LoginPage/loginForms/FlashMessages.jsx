// @flow

import React from 'react'
import { ExclamationCircleIcon } from '@patternfly/react-icons'

type FlashMessage = {
  type: string,
  message: string
}

const FlashMessages = ({flashMessages}: {flashMessages: Array<FlashMessage>}) => {
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

export {FlashMessages}
