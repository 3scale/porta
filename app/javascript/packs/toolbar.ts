// TODO: combine with Messages toolbar

import { ToolbarWrapper } from 'Common/components/Toolbar'

import type { Props } from 'Common/components/Toolbar'

document.addEventListener('DOMContentLoaded', () => {
  const table = document.querySelector<HTMLTableElement>('table[data-toolbar-props]')

  if (!table) {
    return
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  const data = table.dataset.toolbarProps!

  const props = JSON.parse(data) as Props

  ToolbarWrapper(props, table)
})
