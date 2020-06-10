import React from 'react'

import { IDeveloperAccount } from 'types'
import { DataListProvider, AccountsTable } from 'components'
import { generateColumns, generateRows } from 'components/pages/accounts'
import { useTranslation } from 'i18n/useTranslation'

interface Props {
  accounts: IDeveloperAccount[]
}

const AccountsDataListTable: React.FunctionComponent<Props> = ({ accounts }) => {
  const { t } = useTranslation('accountsIndex')
  const columns = generateColumns(t)
  const rows = generateRows(accounts)

  const initialState = {
    table: { columns, rows }
  }

  return (
    <DataListProvider initialState={initialState}>
      <AccountsTable />
    </DataListProvider>
  )
}

export { AccountsDataListTable }
