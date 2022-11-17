import { Table, TableBody, TableHeader } from '@patternfly/react-table'
import {
  Button,
  Divider,
  Level,
  LevelItem,
  PageSection,
  PageSectionVariants,
  PaginationVariant,
  Title,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'

import { Pagination } from 'Common/components/Pagination'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
import type { IActions } from '@patternfly/react-table'
import type { Backend } from 'BackendApis/types'

import './IndexPage.scss'

interface Props {
  newBackendPath: string;
  backends: Backend[];
  backendsCount: number;
}

const IndexPage: FunctionComponent<Props> = ({
  newBackendPath,
  backendsCount,
  backends
}) => {
  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Private base URL',
    'Linked products'
  ]

  const tableRows = backends.map((tableRow) => ({
    cells: [
      { title: <Button isInline component="a" href={tableRow.links[1].path} variant="link">{tableRow.name}</Button> },
      tableRow.systemName,
      <span key={tableRow.systemName} className="api-table-timestamp">{tableRow.updatedAt}</span>,
      tableRow.privateEndpoint,
      tableRow.productsCount
    ]
  }))

  const linkToPage = (rowId: number, actionNumber: number) => {
    const { path } = backends[rowId].links[actionNumber]
    window.location.href = path
  }

  const tableActions: IActions = ['Edit', 'Overview', 'Analytics', 'Methods and Metrics', 'Mapping Rules'].map((title, i) => ({
    title,
    onClick: (_event, rowId) => { linkToPage(rowId, i) }
  }))

  return (
    <PageSection id="backend-apis-index-page" variant={PageSectionVariants.light}>
      <Level>
        <LevelItem>
          <Title headingLevel="h1" size="2xl">Backends</Title>
        </LevelItem>
        <LevelItem>
          <Button component="a" href={newBackendPath} variant="primary">
            Create Backend
          </Button>
        </LevelItem>
      </Level>
      <p>Explore and manage all your internal APIs.</p>
      <Divider />
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="top-toolbar">
        <ToolbarItem>
          <ToolbarSearch placeholder="Find a backend" />
        </ToolbarItem>
        <ToolbarItem>
          <Pagination itemCount={backendsCount} />
        </ToolbarItem>
      </Toolbar>
      <Table actions={tableActions} aria-label="Backend APIs Table" cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="bottom-toolbar">
        <ToolbarItem>
          <Pagination itemCount={backendsCount} variant={PaginationVariant.bottom}    />
        </ToolbarItem>
      </Toolbar>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const BackendsIndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<IndexPage {...props} />, containerId) }

export { IndexPage, BackendsIndexPageWrapper, Props }
