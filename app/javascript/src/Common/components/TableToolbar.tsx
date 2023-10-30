/* eslint-disable react/jsx-props-no-spreading */
import { useRef, useState } from 'react'
import { render } from 'react-dom'
import {
  Toolbar as PFToolbar,
  ToolbarContent,
  ToolbarItem,
  Button,
  ToolbarGroup,
  Dropdown,
  KebabToggle,
  OverflowMenu,
  OverflowMenuContent,
  OverflowMenuControl,
  OverflowMenuGroup,
  OverflowMenuItem,
  OverflowMenuDropdownItem
} from '@patternfly/react-core'

import { Pagination } from 'Common/components/Pagination'
import { BulkSelectDropdown } from 'Common/components/BulkSelectDropdown'
import { BulkActionsDropdown } from 'Common/components/BulkActionsDropdown'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { ToolbarSelect } from 'Common/components/ToolbarSelect'

import type { ButtonProps } from '@patternfly/react-core'
import type { Props as SearchInputProps } from 'Common/components/ToolbarSearch'
import type { BulkAction } from 'Common/components/BulkActionsDropdown'
import type { FunctionComponent } from 'react'

interface ToolbarAction extends ButtonProps {
  label: string;
  isPersistent?: boolean;
}

interface ToolbarFilter {
  attribute: string;
  collection: {
    id: string;
    title: string;
  }[];
  placeholder: string;
}

interface Props {
  actions?: ToolbarAction[];
  bulkActions?: BulkAction[];
  filters?: ToolbarFilter[];
  overflow?: ToolbarAction[];
  pageEntries?: number;
  search?: SearchInputProps;
  totalEntries: number;
}

const TableToolbar: FunctionComponent<Props> = ({
  actions,
  bulkActions,
  filters,
  overflow,
  pageEntries,
  search,
  totalEntries
}) => {
  const [currentPageSelectedItemsIds, setCurrentPageSelectedItemsIds] = useState<string[]>([])
  const [allItemsAcrossPagesSelected, setAllItemsAcrossPagesSelected] = useState(false)
  const [isOverflowMenuOpen, setIsOverflowMenuOpen] = useState(false)
  const toolbarRef = useRef<HTMLDivElement>(null)

  return (
    <div ref={toolbarRef}>
      <PFToolbar>
        <ToolbarContent>
          {bulkActions && pageEntries && (
            <ToolbarGroup>
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
            </ToolbarGroup>
          )}
          {search && (
            <ToolbarItem variant="search-filter">
              <ToolbarSearch {...search} />
            </ToolbarItem>
          )}
          {filters && (
            <ToolbarGroup variant="filter-group">
              {filters.map(filter => (
                <ToolbarSelect key={filter.attribute} {...filter} />
              ))}
            </ToolbarGroup>
          )}
          {actions && (
            <ToolbarGroup variant="button-group">
              {actions.map(({ label, ...btnProps }) => (
                <ToolbarItem key={label}>
                  <Button component="a" {...btnProps}>{label}</Button>
                </ToolbarItem>
              ))}
            </ToolbarGroup>
          )}
          {overflow && (
            <ToolbarItem variant="overflow-menu">
              <OverflowMenu breakpoint="xl" breakpointReference={toolbarRef}>
                <OverflowMenuContent>
                  <OverflowMenuGroup groupType="button">
                    {overflow.map(({ label, ...btnProps }) => (
                      <OverflowMenuItem key={label}>
                        <Button component="a" {...btnProps}>{label}</Button>
                      </OverflowMenuItem>
                    ))}
                  </OverflowMenuGroup>
                </OverflowMenuContent>
                <OverflowMenuControl>
                  <Dropdown
                    isFlipEnabled
                    isPlain
                    dropdownItems={overflow.map(({ label, href }) => (
                      <OverflowMenuDropdownItem key={label} isShared component="a" href={href}>
                        {label}
                      </OverflowMenuDropdownItem>
                    ))}
                    isOpen={isOverflowMenuOpen}
                    toggle={<KebabToggle onToggle={setIsOverflowMenuOpen} />}
                    onSelect={() => { setIsOverflowMenuOpen(false) }}
                  />
                </OverflowMenuControl>
              </OverflowMenu>
            </ToolbarItem>
          )}
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={totalEntries} variant="top" />
          </ToolbarItem>
        </ToolbarContent>
      </PFToolbar>
    </div>
  )
}

const TableToolbarWrapper = (props: Props, table: HTMLTableElement): void => {
  const top = document.createElement('div')
  const bottom = document.createElement('div')

  table.insertAdjacentElement('beforebegin', top)
  table.insertAdjacentElement('afterend', bottom)

  // eslint-disable-next-line react/jsx-props-no-spreading
  render(<TableToolbar {...props} />, top)
  render(<Pagination itemCount={props.totalEntries} variant="bottom" />, bottom)
}

export type { Props }
export { TableToolbar, TableToolbarWrapper }
