import React from 'react'
import { sortable } from '@patternfly/react-table'
import { IDeveloperAccount } from 'types'
import { TFunction } from 'i18next'
import { ActionButtonImpersonate } from 'components/developer-accounts'

const generateRows = (accounts: IDeveloperAccount[], isMultitenant = false) => {
  // Rows and Columns must have the same order
  const mapAccountToRowCell = (account: IDeveloperAccount) => [
    ...[
      account.org_name,
      account.admin_name,
      account.created_at
    ],
    ...account.plan ? [account.plan] : [],
    ...[
      account.apps_count.toString(),
      account.state,
      {
        title: isMultitenant ? <ActionButtonImpersonate /> : ''
      }
    ]
  ]

  return accounts.map((a) => ({
    key: String(a.id),
    cells: mapAccountToRowCell(a),
    selected: false
  }))
}

const generateColumns = (accounts: IDeveloperAccount[], t: TFunction) => [
  ...[{
    title: t('accounts_table.col_group'),
    transforms: [sortable]
  },
  {
    title: t('accounts_table.col_admin'),
    transforms: [sortable]
  },
  {
    title: t('accounts_table.col_signup'),
    transforms: [sortable]
  }],
  // Add this column only when PAID?
  ...accounts[0].plan !== undefined ? [{
    title: t('accounts_table.col_plan'),
    transforms: [sortable]
  }] : [],
  ...[{
    title: t('accounts_table.col_apps'),
    transforms: [sortable]
  },
  {
    title: t('accounts_table.col_state'),
    transforms: [sortable]
  },
  {
    title: t('accounts_table.col_actions')
  }]
]

export { generateColumns, generateRows }
