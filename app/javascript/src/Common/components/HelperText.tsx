// TODO: Replace this component when updating patternfly-react.

import { FunctionComponent, PropsWithChildren } from 'react'

import './HelperText.scss'

const HelperText: FunctionComponent<PropsWithChildren> = ({ children }) => (
  <div className="pf-c-helper-text">
    {children}
  </div>
)

const HelperTextItem: FunctionComponent<PropsWithChildren> = ({ children }) => (
  <div className="pf-c-helper-text__item">
    <span className="pf-c-helper-text__item-text">{children}</span>
  </div>
)

export { HelperText, HelperTextItem }
