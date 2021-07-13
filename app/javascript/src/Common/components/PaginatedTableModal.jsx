// @flow

import * as React from 'react'
import { useState, useEffect, useRef } from 'react'

import {
  Button,
  Modal,
  InputGroup,
  TextInput,
  Pagination,
  Spinner,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableHeader,
  TableBody,
  SortByDirection
} from '@patternfly/react-table'
import { SearchIcon } from '@patternfly/react-icons'
import { NoMatchFound } from 'Common'

import type { Record } from 'utilities'

import './TableModal.scss'

type Props<T: Record> = {
  title: string,
  selectedItem: T | null,
  pageItems?: T[],
  itemsCount: number,
  onSelect: (T | null) => void,
  onClose: () => void,
  cells: Array<{ title: string, propName: string, transforms?: any }>,
  isOpen?: boolean,
  isLoading?: boolean,
  page: number,
  setPage: (number) => void,
  perPage?: number,
  // searchInputRef: {| current: null | React$ElementRef<typeof HTMLInputElement> |},
  onSearch: (term: string) => void,
  sortBy: { index: number, direction: $Keys<typeof SortByDirection> }
}

const PER_PAGE_DEFAULT = 5

const PaginatedTableModal = <T: Record>({
  title,
  isOpen,
  isLoading = false,
  selectedItem,
  pageItems = [],
  itemsCount,
  onSelect,
  onClose,
  cells,
  perPage = PER_PAGE_DEFAULT,
  page,
  setPage,
  onSearch,
  sortBy
}: Props<T>): React.Node => {
  const [selected, setSelected] = useState<T | null>(selectedItem)
  const searchInputRef = useRef<HTMLInputElement | null>(null)

  // TODO: useSearchInputEffect to search on Enter pressed

  useEffect(() => {
    // Need to use effect since selected won't be re-declared on param item selectedItem change
    setSelected(selectedItem)
  }, [selectedItem])

  const handleOnSelect = (_e, _i, rowId: number) => {
    setSelected(pageItems[rowId])
  }

  const handleOnClickSearch = () => {
    if (searchInputRef.current) {
      onSearch(searchInputRef.current.value)
    }
  }

  const pagination = (
    <Pagination
      perPage={perPage}
      itemCount={itemsCount}
      page={page}
      onSetPage={(_e, page) => setPage(page)}
      widgetId="pagination-options-menu-top"
      isDisabled={isLoading}
    />
  )

  const rows = pageItems.map((i) => ({
    selected: i.id === selected?.id,
    cells: cells.map(({ propName }) => i[propName])
  }))

  const onAccept = () => {
    onSelect(selected)
  }

  const onCancel = () => {
    setSelected(selectedItem)
    onClose()
  }

  const actions = [
    <Button
      key="Select"
      variant="primary"
      isDisabled={selected === null || isLoading}
      onClick={onAccept}
      data-testid="select"
    >
      Select
    </Button>,
    <Button
      key="Cancel"
      variant="secondary"
      isDisabled={isLoading}
      onClick={onCancel}
      data-testid="cancel"
    >
      Cancel
    </Button>
  ]

  return (
    <Modal
      isLarge
      title={title}
      isOpen={isOpen}
      onClose={onCancel}
      isFooterLeftAligned={true}
      actions={actions}
    >
      {/* Toolbar is a component in the css, but a layout in react, so the class names are mismatched (pf-c-toolbar vs pf-l-toolbar) Styling doesn't work, but if you change it to pf-c in the inspector, it works */}
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <InputGroup>
            <TextInput
              type="search"
              aria-label="search for an item"
              ref={searchInputRef}
              isDisabled={isLoading}
            />
            <Button
              variant="control"
              aria-label="search button for search input"
              onClick={handleOnClickSearch}
              data-testid="search"
              isDisabled={isLoading}
            >
              <SearchIcon />
            </Button>
          </InputGroup>
        </ToolbarItem>
        <ToolbarItem>
          {pagination}
        </ToolbarItem>
      </Toolbar>
      {isLoading ? <Spinner size='xl' /> : rows.length === 0 ? <NoMatchFound /> : (
        <Table
          aria-label={title}
          sortBy={sortBy}
          onSort={() => {}}
          onSelect={handleOnSelect}
          cells={cells}
          rows={rows}
          selectVariant='radio'
        >
          <TableHeader />
          <TableBody />
        </Table>
      )}
      {pagination}
    </Modal>
  )
}

export { PaginatedTableModal }
