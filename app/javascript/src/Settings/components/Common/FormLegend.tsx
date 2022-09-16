// TODO: Replace this component when patternfly-react implements it.

import * as React from 'react'

type Props = React.HTMLAttributes<HTMLLegendElement>

const FormLegend: React.FunctionComponent<React.HTMLAttributes<HTMLLegendElement>> = ({ children, className = '', ...props }) => (
  <legend {...props} className={`pf-c-form__legend ${className}`}>
    {children}
  </legend>
)

export { FormLegend, Props }
