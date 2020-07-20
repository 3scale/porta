import React, { useEffect } from 'react'
import {
  Table,
  TableHeader,
  TableBody,
  OnSort
} from '@patternfly/react-table'
import {
  PageEmptyState,
  useDataListFilters,
  useDataListPagination,
  useDataListTable,
  Toolbar,
  SearchWidget,
  PaginationWidget,
  filterRows
} from 'components'
import { useTranslation } from 'i18n/useTranslation'
import { ToolbarContent, ToolbarItem } from '@patternfly/react-core'
import { IApplication, IPlan } from 'types'

interface Props {
  applications: IApplication[]
}

const ApplicationsTable: React.FunctionComponent<Props> = ({ applications }) => {
  const { t } = useTranslation('applicationsIndex')
  const {
    columns,
    rows,
    sortBy,
    setSortBy
  } = useDataListTable()

  if (rows.length === 0) {
    return <PageEmptyState msg={t('applications_table.empty_state')} />
  }

  const { startIdx, endIdx, resetPagination } = useDataListPagination()
  const { filters } = useDataListFilters()

  const planOptions = applications.reduce(
    (plans, { plan }) => (plans.find((p) => p.id === plan.id) ? plans : [...plans, plan]),
    [] as IPlan[]
  ).map((plan) => ({
    name: String(plan.id),
    humanName: plan.name
  }))

  const stateOptions = [
    { name: 'live', humanName: t('actions_filter_options.by_state_options.live') },
    { name: 'pending', humanName: t('actions_filter_options.by_state_options.pending') },
    { name: 'suspended', humanName: t('actions_filter_options.by_state_options.suspended') }
  ]

  const categories = [
    { name: 'name', humanName: t('applications_table.name_header') },
    { name: 'account', humanName: t('applications_table.account_header') },
    { name: 'plan', humanName: t('applications_table.plan_header'), options: planOptions },
    { name: 'state', humanName: t('applications_table.state_header'), options: stateOptions }
  ]

  useEffect(() => resetPagination, [filters])

  const filteredRows = filterRows(rows, filters, columns)

  const visibleRows = filteredRows.slice(startIdx, endIdx)

  const onSort: OnSort = (_event, index, direction) => {
    setSortBy(index, direction)
  }

  const pagination = <PaginationWidget itemCount={filteredRows.length} />

  const Header = (
    <Toolbar>
      <ToolbarContent>
        <ToolbarItem>
          <SearchWidget categories={categories} />
        </ToolbarItem>
        <ToolbarItem variant="pagination">
          {pagination}
        </ToolbarItem>
      </ToolbarContent>
    </Toolbar>
  )

  return (
    <>
      <Table
        aria-label={t('applications_table.aria_label')}
        header={Header}
        cells={columns}
        rows={visibleRows}
        canSelectAll={false}
        sortBy={sortBy}
        onSort={onSort}
      >
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="pagination">
            {pagination}
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
    </>
  )
}

export { ApplicationsTable }
