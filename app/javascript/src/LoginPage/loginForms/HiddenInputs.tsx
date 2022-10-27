import { CSRFToken } from 'utilities/CSRFToken'

import type { FunctionComponent } from 'react'

interface Props {
  isPasswordReset?: boolean;
}

const HiddenInputs: FunctionComponent<Props> = ({ isPasswordReset = false }) => (
  <>
    <input name="utf8" type="hidden" value="✓" />
    {isPasswordReset && <input name="_method" type="hidden" value="delete" />}
    <CSRFToken />
  </>
)

export { HiddenInputs, Props }
