import React from 'react'
import { sortable } from '@patternfly/react-table'
import { IDeveloperAccount, DataListRowGenerator, DataListColumnGenerator } from 'types'
import { AccountOverviewLink } from 'components/pages/accounts'

const generateRows: DataListRowGenerator = (accounts: IDeveloperAccount[]) => {
  // Rows and Columns must have the same order
  const mapAccountToRowCell = (account: IDeveloperAccount) => [
    {
      stringValue: account.orgName,
      title: <AccountOverviewLink account={account} />
    },
    account.adminName,
    account.createdAt,
    account.state
  ]

  return accounts.map((a) => ({
    id: a.id,
    cells: mapAccountToRowCell(a),
    selected: false
  }))
}

// Filterable columns must have an id equal to its category name
const generateColumns: DataListColumnGenerator = (t) => [
  {
    categoryName: 'group',
    title: t('accountsIndex:accounts_table.group_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'admin',
    title: t('accountsIndex:accounts_table.admin_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'signup',
    title: t('accountsIndex:accounts_table.signup_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'state',
    title: t('accountsIndex:accounts_table.state_header'),
    transforms: [sortable]
  }
]

export { generateColumns, generateRows }
