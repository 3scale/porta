import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
// @ts-ignore
import { useA11yRouteChange, useDocumentTitle, useAlertsContext } from 'components'
import {
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
  useDataListBulkActions
} from 'components/data-list'
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
import { TableHeader, TableBody, Table } from '@patternfly/react-table'


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
        name: 'active',
        humanName: 'Active'
      },
      {
        name: 'pending',
        humanName: 'Pending'
      }
    ]
  }
]

const tableData = {
  columns: [
    { title: 'Name' },
    { title: 'Surname' }
  ],
  rows: new Array(1000).fill(0).map((_, i) => ({
    id: i,
    cells: [`Name ${i}`, `Surname ${i}`],
    selected: false
  }))
}

const DataListTable = () => {
  const { startIdx, endIdx } = useDataListPagination()
  const {
    columns,
    rows,
    selectOne,
    selectAll
  } = useDataListTable()

  const { modal, setModal } = useDataListBulkActions()

  return (
    <>
      <Table
        aria-label="data-list-table"
        cells={columns}
        rows={rows.slice(startIdx, endIdx)}
        onSelect={(_ev, selected, _rowIndex, rowData) => (_rowIndex === -1
          ? selectAll(selected)
          : selectOne(rowData.id, selected)
        )}
        canSelectAll
      >
        <TableHeader />
        <TableBody />
      </Table>
      {modal === 'sendEmail' && (
        <SendEmailModal
          items={['1', '2', '3', '4', '5', '6']}
          onClose={() => setModal(undefined)}
        />
      )}
      {modal === 'changeState' && (
        <ChangeStateModal
          items={['1', '2', '3', '4', '5', '6']}
          onClose={() => setModal(undefined)}
        />
      )}
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
            <DataListProvider initialState={{ table: tableData }}>
              <Toolbar>
                <ToolbarContent>
                  <ToolbarItem>
                    {/* filteredRows should be inside the context? */}
                    <BulkSelectorWidget filteredRows={tableData.rows} />
                  </ToolbarItem>
                  <ToolbarItem>
                    <BulkActionsWidget actions={actions} />
                  </ToolbarItem>
                  <ToolbarItem>
                    <SearchWidget categories={categories} />
                  </ToolbarItem>
                  <ToolbarItem>
                    <PaginationWidget itemCount={1000} />
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
