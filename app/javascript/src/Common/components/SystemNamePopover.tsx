import { render } from 'react-dom'
import { Popover } from '@patternfly/react-core'
import OutlinedQuestionCircleIcon from '@patternfly/react-icons/dist/js/icons/outlined-question-circle-icon'

const SystemNamePopover: React.FunctionComponent = () => (
  <Popover
    aria-label="system name info popover"
    bodyContent={(
      <div style={{ textAlign: 'start' }}>
        The system name of methods and metrics includes a numeric string that identifies the backend they are mapped to. You cannot modify this backend identifier.
      </div>
    )}
    maxWidth="420px"
  >
    <OutlinedQuestionCircleIcon />
  </Popover>
)

const SystemNamePopoverWrapper = (container: Element): void => { render(<SystemNamePopover />, container) }

export { SystemNamePopover, SystemNamePopoverWrapper }
