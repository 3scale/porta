// @flow
// TODO: Replace this component when patternfly-react implements it.

import * as React from 'react'

import { FormContext } from '@patternfly/react-core/dist/js/components/Form/FormContext'
// $FlowFixMe[cannot-resolve-module] to fix this, try import via scss
import styles from '@patternfly/react-styles/css/components/Form/form'
import { css } from '@patternfly/react-styles'

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
}: Props): React.Node => (
  <FormContext.Consumer>
    {({ isHorizontal }: { isHorizontal: boolean }) => (
      <fieldset
        {...props}
        className={css(styles.formFieldset, isInline ? styles.modifiers.inline : className)}
      >
        {isHorizontal ? <div className={css(styles.formHorizontalGroup)}>{children}</div> : children}
      </fieldset>
    )}
  </FormContext.Consumer>
)

export {
  FormFieldset
}
