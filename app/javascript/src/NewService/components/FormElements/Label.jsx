// @flow

import * as React from 'react'

type Props = {
  htmlFor: string,
  label: string,
  required?: boolean
}
const Label = (props: Props): React.Node => {
  const { htmlFor, label, required } = props
  return <label htmlFor={htmlFor}>{label}
    {required && <abbr title="required">*</abbr>}
  </label>
}

export { Label }
