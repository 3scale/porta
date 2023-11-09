import { TableToolbarWrapper } from 'Common/components/TableToolbar'

import type { Props } from 'Common/components/TableToolbar'

document.addEventListener('DOMContentLoaded', () => {
  const table = document.querySelector<HTMLTableElement>('table[data-toolbar-props]')

  if (!table) {
    return
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  const data = table.dataset.toolbarProps!

  const props = JSON.parse(data) as Props

  TableToolbarWrapper(props, table)
})
