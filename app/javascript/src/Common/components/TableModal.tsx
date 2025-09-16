import { useEffect, useRef, useState } from 'react'
import {
  Button,
  Flex,
  FlexItem,
  Modal,
  ModalVariant,
  Pagination,
  Spinner,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableBody,
  TableHeader
} from '@patternfly/react-table'

import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { NoMatchFound } from 'Common/components/NoMatchFound'
import type { IRecord } from 'utilities/patternfly-utils'

import type {
  IRow,
  IRowCell,
  ITransform,
  SortByDirection,
  TableProps
} from '@patternfly/react-table'

import './TableModal.scss'

interface Props<T extends IRecord> {
  title: string;
  selectedItem: T | null;
  disabledItems?: T[];
  pageItems?: T[];
  itemsCount: number;
  onSelect: (selected: T | null) => void;
  onClose: () => void;
  cells: {
    title: string;
    propName: keyof T;
    transforms?: ITransform[];
  }[];
  isOpen?: boolean;
  isLoading?: boolean;
  page: number;
  setPage: (page: number) => void;
  onSearch: (term: string) => void;
  searchQuery?: string;
  searchPlaceholder?: string;
  perPage?: number;
  sortBy: {
    index: number;
    direction: keyof typeof SortByDirection;
  };
}

const PER_PAGE_DEFAULT = 5

const emptyArray = [] as never[]

const TableModal = <T extends IRecord>({
  title,
  isOpen,
  isLoading = false,
  selectedItem,
  disabledItems,
  pageItems = emptyArray,
  itemsCount,
  onSelect,
  onClose,
  cells,
  perPage = PER_PAGE_DEFAULT,
  page,
  setPage,
  onSearch,
  searchPlaceholder,
  searchQuery,
  sortBy
}: Props<T>): React.ReactElement => {
  const [selected, setSelected] = useState<T | null>(selectedItem)
  const searchInputRef = useRef<HTMLInputElement | null>(null)

  // FIXME: this should really be done by useSearchInputEffect. The ref won't work though. searchInputRef.current is defined only after the first search even though the effect won't be trigger
  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- FIXME: is onSearch really never undefined?
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

  const handleOnSelect = (_e: unknown, _i: unknown, rowId: number) => {
    setSelected(pageItems[rowId])
  }

  // TODO: can we use Common/components/Pagination.tsx here?
  const pagination = (
    <Pagination
      className="pf-c-pagination__input-auto-width"
      isDisabled={isLoading}
      itemCount={itemsCount}
      page={page}
      perPage={perPage}
      widgetId="pagination-options-menu-top"
      onSetPage={(_e, p) => { setPage(p) }}
    />
  )

  const rows: IRow[] = pageItems.map((i) => ({
    selected: i.id === selected?.id,
    disableSelection: disabledItems?.some(disabled => disabled.id === i.id),
    cells: cells.map(({ propName }) => i[propName]) as IRowCell[]
  }))

  // eslint-disable-next-line @typescript-eslint/no-unused-vars -- Don't pass rowProps down to tr
  const customRowWrapper: TableProps['rowWrapper'] = ({ trRef, className, row, rowProps, ...props }) => {
    const classNames = row?.disableSelection ? `pf-c-table__disabled-row ${className ?? ''}` : className
    return (
      // @ts-expect-error: Type mismatch due to @patternfly/react-core being old probably.
      <tr
        // eslint-disable-next-line react/jsx-props-no-spreading
        {...props}
        className={classNames}
        ref={trRef as React.LegacyRef<HTMLTableRowElement>}
      />
    )
  }

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
      isDisabled={selected === null || isLoading || disabledItems?.includes(selected)}
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
      actions={actions}
      aria-label={title}
      isOpen={isOpen}
      title={title}
      variant={ModalVariant.large}
      onClose={onCancel}
    >
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <ToolbarSearch placeholder={searchPlaceholder} searchQuery={searchQuery} onSubmitSearch={onSearch} />
          </ToolbarItem>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            {pagination}
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
      {isLoading ? (
        <Flex justifyContent={{ default: 'justifyContentCenter' }}>
          <FlexItem>
            <Spinner size="lg" />
          </FlexItem>
        </Flex>
      ) : rows.length === 0 ? <NoMatchFound /> : (
        <Table
          aria-label={title}
          cells={cells}
          rowWrapper={customRowWrapper}
          rows={rows}
          selectVariant="radio"
          sortBy={sortBy}
          onSelect={handleOnSelect}
        >
          <TableHeader />
          <TableBody />
        </Table>
      )}
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            {pagination}
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
    </Modal>
  )
}

export type { Props }
export { TableModal }
