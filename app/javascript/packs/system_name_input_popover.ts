import { SystemNamePopoverWrapper } from 'Common/components/SystemNamePopover'

document.addEventListener('DOMContentLoaded', function () {
  const containerId = 'system_name_popover'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  SystemNamePopoverWrapper(container)
})
