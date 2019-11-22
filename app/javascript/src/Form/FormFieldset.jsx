// @flow
// TODO: Replace this component when patternfly-react implements it.

import * as React from 'react'
// $FlowFixMe Flow has troubles with @patternfly modules
import { FormContext } from '@patternfly/react-core/dist/js/components/Form/FormContext'
// $FlowFixMe Flow has troubles with @patternfly modules
import styles from '@patternfly/react-styles/css/components/Form/form'
// $FlowFixMe Flow has troubles with @patternfly modules
import { css, getModifier } from '@patternfly/react-styles'

type Props = {
  children?: React.Node,
  className?: string,
  isInline?: boolean
}

const FormFieldset = ({
  children,
  className = '',
  isInline = false,
  ...props
}: Props) => (
  <FormContext.Consumer>
    {({ isHorizontal }: { isHorizontal: boolean }) => (
      <fieldset
        {...props}
        className={css(styles.formFieldset, isInline ? getModifier(styles, 'inline', className) : className)}
      >
        {isHorizontal ? <div className={css(styles.formHorizontalGroup)}>{children}</div> : children}
      </fieldset>
    )}
  </FormContext.Consumer>
)

export {
  FormFieldset
}
