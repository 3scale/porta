import * as React from 'react'
import { render } from 'react-dom'

import { Popover } from '@patternfly/react-core'

import './SystemNamePopover.scss'

const Popopover: any = Popover // HACK: remove this after upgrading @patternfly/react-core

const SystemNamePopover: React.FunctionComponent = () => (
  <Popopover
    maxWidth="420px"
    aria-label="system name info popover"
    bodyContent={
      <div style={{ textAlign: 'start' }}>The system name of methods and metrics includes a numeric string that identifies the backend they are mapped to. You cannot modify this backend identifier.</div>
    }
  >
    <i className="fa fa-question-circle-o"/>
  </Popopover>
)

const SystemNamePopoverWrapper = (container: Element): void => render(<SystemNamePopover />, container)

export { SystemNamePopover, SystemNamePopoverWrapper }
