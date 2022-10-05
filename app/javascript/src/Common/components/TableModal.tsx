import { useEffect, useRef, useState } from 'react'
import {
  Button,
  InputGroup,
  Modal,
  Pagination,
  Spinner,
  TextInput,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableBody,
  TableHeader
} from '@patternfly/react-table'
import { SearchIcon } from '@patternfly/react-icons'
import { NoMatchFound } from 'Common/components/NoMatchFound'

import type {
  IRow,
  IRowCell,
  ITransform,
  SortByDirection
} from '@patternfly/react-table'
import type { Record } from 'utilities/patternfly-utils'

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
}

const PER_PAGE_DEFAULT = 5

const TableModal = <T extends Record>({
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
}: Props<T>): React.ReactElement => {
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
      isDisabled={isLoading}
      itemCount={itemsCount}
      page={page}
      perPage={perPage}
      widgetId="pagination-options-menu-top"
      onSetPage={(_e, page) => setPage(page)}
    />
  )

  const rows: IRow[] = pageItems.map((i) => ({
    selected: i.id === selected?.id,
    cells: cells.map(({ propName }) => i[propName]) as IRowCell[]
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
      data-testid="select"
      isDisabled={selected === null || isLoading}
      variant="primary"
      onClick={onAccept}
    >
      Select
    </Button>,
    <Button
      key="Cancel"
      data-testid="cancel"
      isDisabled={isLoading}
      variant="secondary"
      onClick={onCancel}
    >
      Cancel
    </Button>
  ]

  return (
    <Modal
      isFooterLeftAligned
      isLarge
      actions={actions}
      isOpen={isOpen}
      title={title}
      onClose={onCancel}
    >
      {/* Toolbar is a component in the css, but a layout in react, so the class names are mismatched (pf-c-toolbar vs pf-l-toolbar) Styling doesn't work, but if you change it to pf-c in the inspector, it works */}
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <InputGroup>
            <TextInput
              aria-label="search for an item"
              isDisabled={isLoading || !onSearch}
              placeholder={searchPlaceholder}
              ref={searchInputRef}
              type="search"
            />
            <Button
              aria-label="search button for search input"
              data-testid="search"
              isDisabled={isLoading || !onSearch}
              variant="control"
              onClick={handleOnClickSearch}
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
          cells={cells}
          rows={rows}
          selectVariant='radio'
          sortBy={sortBy}
          onSelect={handleOnSelect}
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
