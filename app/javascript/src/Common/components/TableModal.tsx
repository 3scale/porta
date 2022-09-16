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
  SortByDirection,
  IRow,
  ITransform
} from '@patternfly/react-table'
import { SearchIcon } from '@patternfly/react-icons'
import { NoMatchFound } from 'Common'

import type { Record } from 'utilities'

import './TableModal.scss'

type Props<T extends Record> = {
  title: string,
  selectedItem: T | null,
  pageItems?: T[],
  itemsCount: number,
  onSelect: (arg1: T | null) => void,
  onClose: () => void,
  cells: Array<{
    title: string,
    propName: keyof T,
    transforms?: ITransform[]
  }>,
  isOpen?: boolean,
  isLoading?: boolean,
  page: number,
  setPage: (arg1: number) => void,
  onSearch: (term: string) => void,
  searchPlaceholder?: string,
  perPage?: number,
  sortBy: {
    index: number,
    direction: keyof typeof SortByDirection
  }
};

const PER_PAGE_DEFAULT = 5

const TableModal = <T extends Record>(
  {
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
    searchPlaceholder,
    sortBy
  }: Props<T>
): React.ReactElement => {
  const [selected, setSelected] = useState<T | null>(selectedItem)
  const searchInputRef = useRef<HTMLInputElement | null>(null)

  // FIXME: this should really be done by useSearchInputEffect. The ref won't work though. searchInputRef.current is defined only after the first search even though the effect won't be trigger
  useEffect(() => {
    if (searchInputRef.current && onSearch) {
      const { current } = searchInputRef

      current.addEventListener('input', (evt: Event) => {
        if (!(evt as InputEvent).inputType) onSearch('')
      })

      current.addEventListener('keydown', ({
        key
      }: KeyboardEvent) => {
        if (key === 'Enter' && searchInputRef.current) onSearch(searchInputRef.current.value)
      })
    }
  }, [searchInputRef])

  useEffect(() => {
    // Need to use effect since selected won't be re-declared on param item selectedItem change
    setSelected(selectedItem)
  }, [selectedItem])

  const handleOnSelect = (_e: any, _i: any, rowId: number) => {
    setSelected(pageItems[rowId])
  }

  const handleOnClickSearch = () => {
    if (searchInputRef.current) {
      onSearch(searchInputRef.current.value)
    }
  }

  const pagination = (
    <Pagination
      className='pf-c-pagination__input-auto-width'
      perPage={perPage}
      itemCount={itemsCount}
      page={page}
      onSetPage={(_e, page) => setPage(page)}
      widgetId="pagination-options-menu-top"
      isDisabled={isLoading}
    />
  )

  const rows: IRow[] = pageItems.map((i) => ({
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
              isDisabled={isLoading || !onSearch}
              placeholder={searchPlaceholder}
            />
            <Button
              variant="control"
              aria-label="search button for search input"
              onClick={handleOnClickSearch}
              data-testid="search"
              isDisabled={isLoading || !onSearch}
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
      <Toolbar className="pf-c-toolbar">
        <ToolbarItem>
          {pagination}
        </ToolbarItem>
      </Toolbar>
    </Modal>
  )
}

export { TableModal, Props }
