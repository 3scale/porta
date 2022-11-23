/* TODO: Replace this components when updating patternfly-react. */

import type { FunctionComponent, PropsWithChildren } from 'react'

import './FormAlert.scss'

export const FormAlert: FunctionComponent<PropsWithChildren> = ({ children }) => (
  <div className="pf-c-form__alert">
    { children }
  </div>  
)
