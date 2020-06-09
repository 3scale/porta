import React from 'react'

import { IDeveloperAccount } from 'types'
import { DataListProvider, AccountsListingTable } from 'components'
import { generateColumns, generateRows } from 'components/pages/accounts'
import { useTranslation } from 'i18n/useTranslation'

const isMultitenant = false // TODO: get this somehow

interface Props {
  accounts: IDeveloperAccount[]
}

const AccountsDataListTable: React.FunctionComponent<Props> = ({ accounts }) => {
  const { t } = useTranslation('audienceAccountsListing')
  const columns = generateColumns(t)
  const rows = generateRows(accounts, isMultitenant)

  const initialState = {
    table: { columns, rows }
  }

  return (
    <DataListProvider initialState={initialState}>
      <AccountsListingTable />
    </DataListProvider>
  )
}

export { AccountsDataListTable }
