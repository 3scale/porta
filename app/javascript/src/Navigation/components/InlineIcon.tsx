import { Icon } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

import './InlineIcon.scss'

interface Props {
  icon: string;
  toggle?: boolean;
}

const InlineIcon: FunctionComponent<Props> = ({ icon, toggle }) => {
  const className = toggle ? 'pf-c-icon__toggle-inline-icon' : 'pf-c-icon__inline-icon'

  return (
    <Icon isInline className={className}>
      <i aria-hidden="true" className={`fa fa-${icon}`} />
    </Icon>
  )
}

export type { Props }
export { InlineIcon }
