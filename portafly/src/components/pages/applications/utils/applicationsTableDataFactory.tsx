import React from 'react'
import { sortable } from '@patternfly/react-table'
import { DataListRowGenerator, DataListColumnGenerator, IProductApplication } from 'types'
import { TFunction } from 'i18next'
import {
  ApplicationPageLink,
  PlanOverviewLink,
  AccountOverviewLink,
  StateLabel
} from 'components'

const generateRows: DataListRowGenerator = (applications: IProductApplication[]) => {
  // Rows and Columns must have the same order
  const mapAccountToRowCell = (application: IProductApplication) => [
    {
      stringValue: application.name,
      title: <ApplicationPageLink application={application} />
    },
    {
      stringValue: application.account.org_name,
      title: <AccountOverviewLink account={application.account} />
    },
    {
      stringValue: application.plan.name,
      title: <PlanOverviewLink plan={application.plan} />
    },
    application.created_on,
    {
      stringValue: application.state,
      title: <StateLabel state={application.state} />
    }
  ]

  return applications.map((a) => ({
    id: a.id,
    cells: mapAccountToRowCell(a),
    selected: false
  }))
}

// Filterable columns must have an id equal to its category name
const generateColumns: DataListColumnGenerator = (t: TFunction) => [
  {
    categoryName: 'name',
    title: t('applicationsIndex:applications_table.name_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'account',
    title: t('applicationsIndex:applications_table.account_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'plan',
    title: t('applicationsIndex:applications_table.plan_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'created_on',
    title: t('applicationsIndex:applications_table.created_header'),
    transforms: [sortable]
  },
  {
    categoryName: 'state',
    title: t('applicationsIndex:applications_table.state_header'),
    transforms: [sortable]
  }
]

export { generateColumns, generateRows }
