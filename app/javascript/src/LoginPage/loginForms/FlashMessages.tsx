import { ExclamationCircleIcon } from '@patternfly/react-icons'

import type { FunctionComponent } from 'react'
import type { FlashMessage } from 'Types'

interface Props {
  flashMessages: FlashMessage[];
}

const FlashMessages: FunctionComponent<Props> = ({ flashMessages }) => (
  <div>
    {flashMessages.map(message => (
      <p
        key={message.message}
        className={`pf-c-form__helper-text pf-m-${message.type}`}
      >
        <ExclamationCircleIcon />
        {` ${message.message}`}
      </p>
    ))}
  </div>
)

export { FlashMessages, Props }
