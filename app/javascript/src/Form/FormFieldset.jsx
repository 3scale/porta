// @flow
// TODO: Replace this component when patternfly-react implements it.

import * as React from 'react'
import { FormContext } from '@patternfly/react-core/dist/js/components/Form/FormContext'
// $FlowFixMe
import styles from '@patternfly/react-styles/css/components/Form/form'
// $FlowFixMe
import { css, getModifier } from '@patternfly/react-styles'

type Props = {
  children?: React.Node,
  className?: string,
  label?: React.Node,
  isRequired?: boolean,
  isValid?: boolean,
  isInline?: boolean,
  helperText?: React.Node,
  helperTextInvalid?: React.Node,
  fieldId: string
}

const FormFieldset = ({
  children,
  className = '',
  label,
  isRequired = false,
  isValid = true,
  isInline = false,
  helperText,
  helperTextInvalid,
  fieldId,
  ...props
}: Props) => (
  <FormContext.Consumer>
    {({ isHorizontal }: { isHorizontal: boolean }) => (
      <fieldset
        {...props}
        className={css(styles.formFieldset, isInline ? getModifier(styles, 'inline', className) : className)}
      >
        {label && (
          <label className={css(styles.formLabel)} htmlFor={fieldId}>
            <span className={css(styles.formLabelText)}>{label}</span>
            {isRequired && (
              <span className={css(styles.formLabelRequired)} aria-hidden="true">
                {'*'}
              </span>
            )}
          </label>
        )}
        {isHorizontal ? <div className={css(styles.formHorizontalGroup)}>{children}</div> : children}
        {((isValid && helperText) || (!isValid && helperTextInvalid)) && (
          <div
            className={css(styles.formHelperText, !isValid ? getModifier(styles, 'error') : '')}
            id={`${fieldId}-helper`}
            aria-live="polite"
          >
            {isValid ? helperText : helperTextInvalid}
          </div>
        )}
      </fieldset>
    )}
  </FormContext.Consumer>
)

export {
  FormFieldset
}
