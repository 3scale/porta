import React from 'react'
import {CSRFToken} from 'utilities/utils'

const HiddenInputs = ({isPasswordReset = false}) => {
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
