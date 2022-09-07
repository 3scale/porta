import {SystemNamePopoverWrapper} from 'Common';

document.addEventListener('DOMContentLoaded', function () {
  const containerId = 'system_name_popover'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  SystemNamePopoverWrapper(container)
})
