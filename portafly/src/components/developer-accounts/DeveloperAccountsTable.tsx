import React, { useState, useMemo } from 'react'
import {
  Table,
  TableHeader,
  TableBody
} from '@patternfly/react-table'
import {
  TablePagination,
  SimpleEmptyState
} from 'components'
import {
  BulkSelector,
  SearchWidget,
  ActionsDropdown,
  generateColumns,
  generateRows
} from 'components/developer-accounts'
import { IDeveloperAccount } from 'types'
import { useTranslation } from 'i18n/useTranslation'
import {
  DataToolbar,
  DataToolbarItem,
  DataToolbarContent
} from '@patternfly/react-core/dist/js/experimental'

interface IDeveloperAccountsTable {
  accounts: IDeveloperAccount[]
  isMultitenant?: boolean
}

const DeveloperAccountsTable: React.FunctionComponent<IDeveloperAccountsTable> = ({
  accounts,
  isMultitenant = false
}) => {
  const { t } = useTranslation('accounts')

  if (accounts.length === 0) {
    return <SimpleEmptyState msg={t('accounts_table.empty_state')} />
  }

  const columns = useMemo(() => generateColumns(accounts, t), [])
  const [rows] = useState(() => generateRows(accounts, isMultitenant))

  const pagination = (
    <TablePagination
      itemCount={rows.length}
      isCompact
    />
  )

  const DataListHeader = () => (
    <DataToolbar id="accounts-toolbar-top" clearAllFilters={() => {}}>
      <DataToolbarContent>
        <DataToolbarItem>
          <BulkSelector
            onSelectAll={() => {}}
            onSelectPage={() => {}}
            pageCount={rows.length}
            allCount={rows.length}
            selectedCount={0}
          />
        </DataToolbarItem>
        <DataToolbarItem>
          <ActionsDropdown isDisabled selectAction={() => {}} />
        </DataToolbarItem>
        <DataToolbarItem>
          <SearchWidget />
        </DataToolbarItem>
        <DataToolbarItem variant="pagination" breakpointMods={[{ modifier: 'align-right', breakpoint: 'md' }]}>
          {pagination}
        </DataToolbarItem>
      </DataToolbarContent>
    </DataToolbar>
  )

  return (
    <>
      <Table
        aria-label={t('accounts_table.aria_label')}
        header={<DataListHeader />}
        cells={columns}
        rows={rows}
        onSelect={() => {}}
        canSelectAll={false}
      >
        <TableHeader />
        <TableBody />
      </Table>
      <DataToolbar id="footer">
        <DataToolbarContent>
          <DataToolbarItem variant="pagination" breakpointMods={[{ modifier: 'align-right', breakpoint: 'md' }]}>
            {pagination}
          </DataToolbarItem>
        </DataToolbarContent>
      </DataToolbar>

      {/* Modals go here */}
    </>
  )
}

export { DeveloperAccountsTable }
