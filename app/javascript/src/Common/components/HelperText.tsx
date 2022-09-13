// TODO: Replace this component when updating patternfly-react.

import * as React from 'react'

import './HelperText.scss'

type HelperTextProps = {
  children: React.ReactNode
};

type HelperTextItemProps = {
  children: string
};

const HelperText = (
  {
    children
  }: HelperTextProps
): React.ReactElement => {
  return (
    <div className="pf-c-helper-text">
      {children}
    </div>
  )
}

const HelperTextItem = (
  {
    children
  }: HelperTextItemProps
): React.ReactElement => {
  return (
    <div className="pf-c-helper-text__item">
      <span className="pf-c-helper-text__item-text">{children}</span>
    </div>
  )
}

export { HelperText, HelperTextItem }
