import { render } from 'react-dom'
import { Popover } from '@patternfly/react-core'

import './SystemNamePopover.scss'

// eslint-disable-next-line @typescript-eslint/naming-convention, @typescript-eslint/no-explicit-any -- HACK: Popover return method is incompatible. Need to upgrade @patternfly/react-core
const Popopover: any = Popover

const SystemNamePopover: React.FunctionComponent = () => (
  <Popopover
    aria-label="system name info popover"
    bodyContent={(
      <div style={{ textAlign: 'start' }}>
        The system name of methods and metrics includes a numeric string that identifies the backend they are mapped to. You cannot modify this backend identifier.
      </div>
    )}
    maxWidth="420px"
  >
    <i className="fa fa-question-circle-o" />
  </Popopover>
)

const SystemNamePopoverWrapper = (container: Element): void => { render(<SystemNamePopover />, container) }

export { SystemNamePopover, SystemNamePopoverWrapper }
