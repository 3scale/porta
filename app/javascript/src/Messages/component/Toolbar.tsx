import { useState } from 'react'
import {
  Button,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import { render } from 'react-dom'

import { Pagination } from 'Common/components/Pagination'
import { BulkActionsDropdown } from 'Common/components/BulkActionsDropdown'
import { BulkSelectDropdown } from 'Common/components/BulkSelectDropdown'

import type { BulkAction } from 'Common/components/BulkActionsDropdown'
import type { FunctionComponent } from 'react'

interface Props {
  bulkActions: BulkAction[];
  newMessageHref: string;
  pageEntries: number;
  totalEntries: number;
}

const TopToolbar: FunctionComponent<Props> = ({
  bulkActions,
  newMessageHref,
  pageEntries,
  totalEntries
}) => {
  const [currentPageSelectedItemsIds, setCurrentPageSelectedItemsIds] = useState<string[]>([])
  const [allItemsAcrossPagesSelected, setAllItemsAcrossPagesSelected] = useState(false)

  return (
    <Toolbar>
      <ToolbarContent>
        <ToolbarItem variant="bulk-select">
          <BulkSelectDropdown
            numSelected={allItemsAcrossPagesSelected ? totalEntries : currentPageSelectedItemsIds.length}
            pageEntries={pageEntries}
            setAllEntriesSelected={setAllItemsAcrossPagesSelected}
            setSelectedItems={setCurrentPageSelectedItemsIds}
            totalEntries={totalEntries}
          />
        </ToolbarItem>
        <ToolbarItem>
          <BulkActionsDropdown
            actions={bulkActions}
            allSelected={allItemsAcrossPagesSelected}
            isDisabled={currentPageSelectedItemsIds.length === 0}
          />
        </ToolbarItem>
        <ToolbarItem alignment={{ default: 'alignRight' }}>
          <Button component="a" href={newMessageHref} variant="primary">Compose Message</Button>
        </ToolbarItem>
        <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
          <Pagination itemCount={totalEntries} />
        </ToolbarItem>
      </ToolbarContent>
    </Toolbar>
  )
}

// eslint-disable-next-line react/no-multi-comp
const BottomToobar: FunctionComponent<{ totalEntries: number }> = ({ totalEntries }) => (
  <Toolbar>
    <ToolbarContent>
      <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
        <Pagination itemCount={totalEntries} />
      </ToolbarItem>
    </ToolbarContent>
  </Toolbar>
)

const ToolbarWrapper = (props: Props, table: HTMLTableElement): void => {
  const top = document.createElement('div')
  const bottom = document.createElement('div')

  table.insertAdjacentElement('beforebegin', top)
  table.insertAdjacentElement('afterend', bottom)

  // eslint-disable-next-line react/jsx-props-no-spreading
  render(<TopToolbar {...props} />, top)
  render(<BottomToobar totalEntries={props.totalEntries} />, bottom)
}

export type { Props }
export { TopToolbar as TheToolbar, ToolbarWrapper }
