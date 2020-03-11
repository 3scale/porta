import React from 'react'
import { Table, TableHeader, TableBody } from '@patternfly/react-table'
import { SimpleEmptyState } from 'components'
import { IApplication } from 'types'

export interface IApplicationsTable {
  applications: IApplication[]
}

const ApplicationsTable: React.FunctionComponent<IApplicationsTable> = ({ applications }) => {
  if (applications.length === 0) {
    return <SimpleEmptyState msg="There are no Applications" />
  }

  const COLUMNS = ['Name', 'State', 'Account', 'Plan', 'Created at']

  const rows = applications.map(app => [app.name, app.state, app.account, app.plan.name, app.created_at])

  return (
    <Table aria-label="Applications list" cells={COLUMNS} rows={rows}>
      <TableHeader />
      <TableBody />
    </Table>
  )
}

export { ApplicationsTable }
