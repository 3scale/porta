// @flow
// TODO: Replace this component when patternfly-react implements it.

import * as React from 'react'

type Props = {
  children?: React.Node,
  className?: string
}

const FormLegend = ({
  children,
  className = '',
  ...props
}: Props) => (
  <legend {...props} className={`pf-c-form__legend ${className}`}>
    {children}
  </legend>
)

export {
  FormLegend
}
