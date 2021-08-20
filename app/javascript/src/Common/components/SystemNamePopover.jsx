// @flow

import * as React from 'react'
import { render } from 'react-dom'

import { Popover } from '@patternfly/react-core'

import './SystemNamePopover.scss'

const SystemNamePopover = (): React.Node => (
  <Popover
    maxWidth="420px"
    aria-label="system name info popover"
    bodyContent={
      <div style={{ textAlign: 'start' }}>The system name of methods and metrics includes a numeric string that identifies the backend they are mapped to. You cannot modify this backend identifier.</div>
    }
  >
    <i className="fa fa-question-circle-o"/>
  </Popover>
)

const SystemNamePopoverWrapper = (container: Element): void => render(<SystemNamePopover />, container)

export { SystemNamePopoverWrapper }
