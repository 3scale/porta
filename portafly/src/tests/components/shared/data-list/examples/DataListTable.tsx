import React, { useEffect } from 'react'
import {
  Table,
  TableHeader,
  TableBody,
  OnSelect,
  OnSort
} from '@patternfly/react-table'
import {
  PageEmptyState,
  useDataListFilters,
  useDataListPagination,
  useDataListTable,
  useDataListBulkActions,
  Toolbar,
  SearchWidget,
  PaginationWidget,
  BulkSelectorWidget,
  ChangeStateModal,
  BulkActionsWidget,
  filterRows,
  SendEmailModal
} from 'components'
import { ToolbarContent, ToolbarItem } from '@patternfly/react-core'
import { DataListRow } from 'types'

const DataListTable: React.FunctionComponent = () => {
  const {
    columns,
    rows,
    sortBy,
    setSortBy,
    selectedRows,
    selectOne
  } = useDataListTable()

  if (rows.length === 0) {
    return <PageEmptyState msg="No characters found" />
  }

  const { startIdx, endIdx, resetPagination } = useDataListPagination()
  const { filters } = useDataListFilters()
  const { modal } = useDataListBulkActions()

  const options = [
    { name: 'alive', humanName: 'Alive' },
    { name: 'deceased', humanName: 'Deceased' }
  ]

  const categories = [
    { name: 'name', humanName: 'Name' },
    { name: 'species', humanName: 'Species' },
    { name: 'state', humanName: 'State', options }
  ]

  useEffect(() => resetPagination, [filters])

  const actions = {
    sendEmail: 'Send Raven',
    changeState: 'Change State'
  }

  const filteredRows = filterRows(rows, filters, columns)

  const visibleRows = filteredRows.slice(startIdx, endIdx)

  const onSort: OnSort = (_event, index, direction) => {
    setSortBy(index, direction, true)
  }

  const onSelectOne: OnSelect = (_ev, selected, _rowIndex, rowData) => {
    selectOne(rowData.id, selected)
  }

  const pagination = <PaginationWidget itemCount={filteredRows.length} />

  const Header = (
    <Toolbar>
      <ToolbarContent>
        <ToolbarItem>
          <BulkSelectorWidget />
        </ToolbarItem>
        <ToolbarItem>
          <BulkActionsWidget actions={actions} />
        </ToolbarItem>
        <ToolbarItem>
          <SearchWidget categories={categories} />
        </ToolbarItem>
        <ToolbarItem variant="pagination">
          {pagination}
        </ToolbarItem>
      </ToolbarContent>
    </Toolbar>
  )

  const extractSendEmailItemTitle = ({ cells }: DataListRow) => `${cells[1]} (${cells[0]})`
  const extractChangeStateItemTitle = ({ cells } :DataListRow) => `${cells[0]} (${cells[4]})`

  return (
    <>
      <Table
        aria-label="Harry Potter characters"
        header={Header}
        cells={columns}
        rows={visibleRows}
        onSelect={visibleRows.length ? onSelectOne : undefined}
        canSelectAll={false}
        sortBy={sortBy}
        onSort={onSort}
      >
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="pagination">
            {pagination}
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      {modal === 'sendEmail' && (
        <SendEmailModal items={selectedRows.map(extractSendEmailItemTitle)} />
      )}

      {modal === 'changeState' && (
        <ChangeStateModal items={selectedRows.map(extractChangeStateItemTitle)} states={options} />
      )}
    </>
  )
}

export { DataListTable }
