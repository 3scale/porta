// @flow

import * as React from 'react'
import { CSRFToken } from 'utilities'

const HiddenInputs = ({ isPasswordReset = false }: {isPasswordReset?: boolean}): React.Node => {
  return (
    <React.Fragment>
      <input name="utf8" type="hidden" value="✓"/>
      {isPasswordReset && <input type="hidden" name="_method" value="delete"/>}
      <CSRFToken/>
    </React.Fragment>
  )
}

export {
  HiddenInputs
}
