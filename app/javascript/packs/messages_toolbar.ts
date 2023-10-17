import { ToolbarWrapper } from 'Messages/component/Toolbar'

import type { Props } from 'Messages/component/Toolbar'

document.addEventListener('DOMContentLoaded', () => {
  const table = document.querySelector<HTMLTableElement>('table.pf-c-table#messages')

  if (!table) {
    throw new Error('Table was not found')
  }

  const data = table.dataset.toolbarProps

  if (!data) {
    throw new Error('missing props for Toolbar')
  }

  const props = JSON.parse(data) as Props

  ToolbarWrapper(props, table)
})
