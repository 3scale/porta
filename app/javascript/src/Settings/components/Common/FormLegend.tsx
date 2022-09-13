// TODO: Replace this component when patternfly-react implements it.

import * as React from 'react'

type Props = {
  children?: React.ReactNode,
  className?: string
};

const FormLegend = (
  {
    children,
    className = '',
    ...props
  }: Props
): React.ReactElement => <legend {...props} className={`pf-c-form__legend ${className}`}>
  {children}
</legend>

export {
  FormLegend
}
