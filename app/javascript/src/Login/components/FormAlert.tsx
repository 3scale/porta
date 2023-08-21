import { HelperText, HelperTextItem } from '@patternfly/react-core'

import type { FlashMessage } from 'Types/FlashMessages'
import type { FunctionComponent } from 'react'

interface Props {
  error?: FlashMessage;
}

const LoginAlert: FunctionComponent<Props> = ({ error }) => (
  <HelperText className={error ? '' : 'invisible'}>
    <HelperTextItem hasIcon={error?.type === 'error'} variant={error?.type as 'error'}>
      {error?.message}
    </HelperTextItem>
  </HelperText>
)

export { LoginAlert }
