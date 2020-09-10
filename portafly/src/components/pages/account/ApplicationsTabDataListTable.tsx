import React from 'react'
import { DataListProvider, ApplicationsTable } from 'components'
import { generateColumns, generateRows } from 'components/pages/account/utils'
import { useTranslation } from 'i18n/useTranslation'
import { IApplication } from 'types'

interface Props {
  applications: IApplication[]
}

const ApplicationsTabDataListTable: React.FunctionComponent<Props> = ({ applications }) => {
  const { t } = useTranslation('accountOverview')
  const columns = generateColumns(t)
  const rows = generateRows(applications)

  const initialState = {
    table: { columns, rows }
  }

  return (
    <DataListProvider initialState={initialState}>
      <ApplicationsTable applications={applications} />
    </DataListProvider>
  )
}

export { ApplicationsTabDataListTable }
