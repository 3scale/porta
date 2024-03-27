import { Table, TableBody, TableHeader } from '@patternfly/react-table'
import {
  Button,
  Divider,
  PageSection,
  PageSectionVariants,
  Text,
  TextContent,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'

import { Pagination } from 'Common/components/Pagination'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
import type { IActions } from '@patternfly/react-table'
import type { Backend } from 'BackendApis/types'

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
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">Backends</Text>
          <Text component="p">Explore and manage all your internal APIs.</Text>
        </TextContent>
      </PageSection>

      <Divider />

      <PageSection variant={PageSectionVariants.light}>
        <Toolbar id="top-toolbar">
          <ToolbarContent>
            <ToolbarItem spacer={{ default: 'spacerMd' }} variant="search-filter">
              <ToolbarSearch placeholder="Find a backend" />
            </ToolbarItem>
            <ToolbarItem>
              <Button component="a" href={newBackendPath} variant="primary">
                Create a backend
              </Button>
            </ToolbarItem>
            <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
              <Pagination itemCount={backendsCount} />
            </ToolbarItem>
          </ToolbarContent>
        </Toolbar>
        <Table actions={tableActions} aria-label="Backend APIs Table" cells={tableColumns} rows={tableRows}>
          <TableHeader />
          <TableBody />
        </Table>
        <Toolbar id="bottom-toolbar">
          <ToolbarContent>
            <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
              <Pagination itemCount={backendsCount} />
            </ToolbarItem>
          </ToolbarContent>
        </Toolbar>
      </PageSection>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const BackendsIndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<IndexPage {...props} />, containerId) }

export type { Props }
export { IndexPage, BackendsIndexPageWrapper }
