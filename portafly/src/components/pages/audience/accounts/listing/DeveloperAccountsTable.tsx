import React from 'react'
import { Table, TableHeader, TableBody } from '@patternfly/react-table'
import { PageEmptyState } from 'components'
import { IDeveloperAccount } from 'types'
import { useTranslation } from 'i18n/useTranslation'

export interface IDeveloperAccountsTable {
  accounts: IDeveloperAccount[]
}

const DeveloperAccountsTable: React.FunctionComponent<IDeveloperAccountsTable> = ({ accounts }) => {
  const { t } = useTranslation('audienceAccountsListing')

  if (accounts.length === 0) {
    return <PageEmptyState msg={t('accounts_table.empty_state')} />
  }

  const COLUMNS = [
    t('accounts_table.group_header'),
    t('accounts_table.admin_header'),
    t('accounts_table.signup_header'),
    t('accounts_table.applications_header'),
    t('accounts_table.state_header')
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
