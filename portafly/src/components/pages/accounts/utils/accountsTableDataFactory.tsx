/* eslint-disable no-nested-ternary */
import React from 'react'
import { sortable } from '@patternfly/react-table'
import { IDeveloperAccount } from 'types'
import { TFunction } from 'i18next'
import { ActionButtonImpersonate, ActionButtonApprove, ActionButtonActivate } from 'components/pages/accounts'

const getActionButtonForAccount = ({ id, state }: IDeveloperAccount) => {
  if (state === 'pending') return <ActionButtonApprove id={String(id)} />
  if (state === 'suspended') return <ActionButtonActivate />
  return ''
}

const generateRows = (accounts: IDeveloperAccount[]) => {
  const isMultitenant = process.env.REACT_APP_MULTITENANT === 'true'
  // Rows and Columns must have the same order
  const mapAccountToRowCell = (account: IDeveloperAccount) => [
    account.org_name,
    account.admin_name,
    account.created_at,
    account.apps_count.toString(),
    account.state,
    {
      title: isMultitenant ? <ActionButtonImpersonate /> : getActionButtonForAccount(account)
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
    title: t('audienceAccountsListing:accounts_table.group_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'admin',
    title: t('audienceAccountsListing:accounts_table.admin_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'signup',
    title: t('audienceAccountsListing:accounts_table.signup_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'apps',
    title: t('audienceAccountsListing:accounts_table.applications_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'state',
    title: t('audienceAccountsListing:accounts_table.state_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'actions',
    title: t('shared:shared_elements.actions_header_plural')
  }
]

export { generateColumns, generateRows }
