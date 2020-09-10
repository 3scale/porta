/* eslint-disable no-console */
import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
import {
  useA11yRouteChange,
  useDocumentTitle,
  useAlertsContext,
  Toolbar,
  DataListProvider,
  SearchWidget,
  PaginationWidget,
  useDataListPagination,
  useDataListTable,
  BulkSelectorWidget,
  BulkActionsWidget,
  ChangeStateModal,
  SendEmailModal,
  useDataListBulkActions,
  filterRows,
  useDataListFilters
} from 'components'
import {
  PageSection,
  TextContent,
  Title,
  Text,
  Card,
  CardBody,
  Button,
  ToolbarItem,
  ToolbarContent
} from '@patternfly/react-core'
import { BellIcon } from '@patternfly/react-icons'
import {
  TableHeader, TableBody, Table, OnSort, sortable
} from '@patternfly/react-table'
import { CategoryOption } from 'types'
import { StateLabel, useDataListData } from 'components/shared'
import { Trans } from 'react-i18next'

const categories = [
  {
    name: 'admin',
    humanName: 'Admin'
  },
  {
    name: 'group',
    humanName: 'Organization / Group'
  },
  {
    name: 'state',
    humanName: 'State',
    options: [
      {
        name: 'approved',
        humanName: 'Active'
      },
      {
        name: 'pending',
        humanName: 'Pending'
      }
    ]
  }
]

const apiData = new Array(1000).fill(0).map((_, i) => ({
  id: i,
  adminName: `Admin ${Math.random() * (i + 1)}`,
  createdAt: i,
  updatedAt: i,
  state: (categories[2] as any).options[i % 2].name,
  orgName: `Group ${Math.random() * (i + 1)}`
}))

const tableData = {
  columns: categories.map((c) => ({
    categoryName: c.name,
    title: c.humanName,
    transforms: [sortable]
  })),
  rows: apiData.map((account) => ({
    id: account.id,
    cells: [
      account.adminName,
      account.orgName,
      {
        stringValue: account.state,
        title: <StateLabel state={account.state} />
      }
    ],
    selected: false
  }))
}

const DataListTable = () => {
  const { startIdx, endIdx } = useDataListPagination()
  const {
    columns,
    rows,
    sortBy,
    setSortBy,
    selectOne,
    selectAll
  } = useDataListTable()
  const { filters } = useDataListFilters()
  const { data } = useDataListData()
  const { modal } = useDataListBulkActions()
  console.log('FetchedData: ', data)
  const onSort: OnSort = (event, index, direction) => {
    setSortBy(index, direction, true)
  }

  const filteredRows = filterRows(rows, filters, columns)
  const pageRows = filteredRows.slice(startIdx, endIdx)
  const states = categories[2].options as CategoryOption[]

  return (
    <>
      <Table
        aria-label="data-list-table"
        cells={columns}
        rows={pageRows}
        onSelect={(_ev, selected, _rowIndex, rowData) => (_rowIndex === -1
          ? selectAll(selected)
          : selectOne(rowData.id, selected)
        )}
        canSelectAll
        sortBy={sortBy}
        onSort={onSort}
      >
        <TableHeader />
        <TableBody />
      </Table>
      {modal === 'sendEmail' && <SendEmailModal items={['1', '2', '3', '4', '5', '6']} />}
      {modal === 'changeState' && <ChangeStateModal items={['1', '2', '3', '4', '5', '6']} states={states} />}
    </>
  )
}

const Overview: React.FunctionComponent = () => {
  const { t } = useTranslation('overview')

  useA11yRouteChange()
  useDocumentTitle(t('page_title'))
  const { addAlert } = useAlertsContext()

  const actions = {
    sendEmail: t('shared:bulk_actions.send_email'),
    changeState: t('shared:bulk_actions.change_state')
  }

  const dataListInitialState = {
    data: apiData,
    filters: {},
    table: tableData
  }

  return (
    <>
      <PageSection variant="light">
        <TextContent>
          <Title headingLevel="h2" size="3xl">{t('body_title')}</Title>
          <Text>
            {t('subtitle')}
          </Text>
        </TextContent>
      </PageSection>
      <PageSection>
        <Card>
          <CardBody>
            <TextContent>
              <p>{t('shared:format.uppercase', { text: 'Ohai' })}</p>
              <p>{t('test_interpolate', { text: 'Ohai' })}</p>
              <p><Trans t={t} i18nKey="test_format" /></p>
              {/* This is just for testing, will be removed */}
              <Button
                icon={<BellIcon />}
                onClick={() => {
                  const id = Date.now().toString()
                  addAlert({ id, variant: 'info', title: `Test Alert ${id}` })
                }}
              >
                Add an Alert
              </Button>
            </TextContent>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <DataListProvider initialState={dataListInitialState}>
              <Toolbar>
                <ToolbarContent>
                  <ToolbarItem>
                    <BulkSelectorWidget />
                  </ToolbarItem>
                  <ToolbarItem>
                    <BulkActionsWidget actions={actions} />
                  </ToolbarItem>
                  <ToolbarItem>
                    <SearchWidget categories={categories} />
                  </ToolbarItem>
                  <ToolbarItem>
                    <PaginationWidget itemCount={tableData.rows.length} />
                  </ToolbarItem>
                </ToolbarContent>
              </Toolbar>
              <DataListTable />
            </DataListProvider>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default Overview
