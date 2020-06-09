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
  SendEmailModal,
  ChangeStateModal,
  BulkActionsWidget,
  filterRows
} from 'components'
import { useTranslation } from 'i18n/useTranslation'
import { ToolbarContent, ToolbarItem } from '@patternfly/react-core'
import { DataListRow } from 'types'

const AccountsTable: React.FunctionComponent = () => {
  const { t } = useTranslation('accountsIndex')
  const {
    columns,
    rows,
    sortBy,
    setSortBy,
    selectedRows,
    selectOne
  } = useDataListTable()

  if (rows.length === 0) {
    return <PageEmptyState msg={t('accounts_table.empty_state')} />
  }

  const { startIdx, endIdx, resetPagination } = useDataListPagination()
  const { filters } = useDataListFilters()
  const { modal } = useDataListBulkActions()

  const options = [
    { name: 'approved', humanName: t('actions_filter_options.by_state_options.approved') },
    { name: 'pending', humanName: t('actions_filter_options.by_state_options.pending') },
    { name: 'rejected', humanName: t('actions_filter_options.by_state_options.rejected') },
    { name: 'suspended', humanName: t('actions_filter_options.by_state_options.suspended') }
  ]

  const categories = [
    { name: 'group', humanName: t('accounts_table.group_header') },
    { name: 'admin', humanName: t('accounts_table.admin_header') },
    { name: 'state', humanName: t('accounts_table.state_header'), options }
  ]

  useEffect(() => resetPagination, [filters])

  const actions = {
    sendEmail: t('shared:bulk_actions.send_email'),
    changeState: t('shared:bulk_actions.change_state')
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
        <ToolbarItem variant="pagination" breakpointMods={[{ modifier: 'align-right', breakpoint: 'md' }]}>
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
        aria-label={t('accounts_table.aria_label')}
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
          <ToolbarItem variant="pagination" breakpointMods={[{ modifier: 'align-right', breakpoint: 'md' }]}>
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

export { AccountsTable }
