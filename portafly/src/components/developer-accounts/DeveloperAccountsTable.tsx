import React from 'react'
import { Table, TableHeader, TableBody } from '@patternfly/react-table'
import { SimpleEmptyState } from 'components'
import { IDeveloperAccount } from 'types'
import { useTranslation } from 'i18n/useTranslation'

export interface IDeveloperAccountsTable {
  accounts: IDeveloperAccount[]
}

const DeveloperAccountsTable: React.FunctionComponent<IDeveloperAccountsTable> = ({ accounts }) => {
  const { t } = useTranslation('accounts')

  if (accounts.length === 0) {
    return <SimpleEmptyState msg={t('accounts_table.empty_state')} />
  }

  const COLUMNS = [
    t('accounts_table.col_group'),
    t('accounts_table.col_admin'),
    t('accounts_table.col_signup'),
    t('accounts_table.col_apps'),
    t('accounts_table.col_state')
  ]

  const rows: string[][] = accounts.map((a) => [
    a.org_name,
    a.admin_name,
    a.created_at,
    a.apps_count.toString(),
    a.state
  ])

  return (
    <Table aria-label={t('accounts_table.aria_label')} cells={COLUMNS} rows={rows}>
      <TableHeader />
      <TableBody />
    </Table>
  )
}

export { DeveloperAccountsTable }
