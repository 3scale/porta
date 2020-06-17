import React from 'react'
import { sortable } from '@patternfly/react-table'
import { IDeveloperAccount } from 'types'
import { TFunction } from 'i18next'
import { ActionButtonImpersonate } from 'components/pages/accounts'

const generateRows = (accounts: IDeveloperAccount[]) => {
  const isMultitenant = process.env.REACT_APP_MULTITENANT
  // Rows and Columns must have the same order
  const mapAccountToRowCell = (account: IDeveloperAccount) => [
    account.org_name,
    account.admin_name,
    account.created_at,
    String(account.apps_count),
    account.state,
    {
      title: isMultitenant ? <ActionButtonImpersonate /> : ''
    }
  ]

  return accounts.map((a) => ({
    id: a.id,
    cells: mapAccountToRowCell(a),
    selected: false
  }))
}

// Filterable columns must have an id equal to its category name
const generateColumns = (t: TFunction) => [
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
    categoryName: 'apps',
    title: t('accountsIndex:accounts_table.applications_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'state',
    title: t('accountsIndex:accounts_table.state_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'actions',
    title: t('shared:shared_elements.actions_header_plural')
  }
]

export { generateColumns, generateRows }
