import React from 'react'
import { DataListProvider, ApplicationsTable } from 'components'
import { generateColumns, generateRows } from 'components/pages/applications/utils'
import { useTranslation } from 'i18n/useTranslation'
import { IApplication } from 'types'

interface Props {
  applications: IApplication[]
}

const ApplicationsDataListTable: React.FunctionComponent<Props> = ({ applications }) => {
  const { t } = useTranslation('applicationsIndex')
  const columns = generateColumns(t)
  const rows = generateRows(applications)

  const initialState = {
    data: applications,
    table: { columns, rows }
  }

  return (
    <DataListProvider initialState={initialState}>
      <ApplicationsTable applications={applications} />
    </DataListProvider>
  )
}

export { ApplicationsDataListTable }
