import {
  Button,
  Divider,
  Level,
  LevelItem,
  OnPerPageSelect,
  PageSection,
  PageSectionVariants,
  Pagination as PFPagination,
  PaginationProps,
  PaginationVariant,
  Title,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import { Table, TableHeader, TableBody, IActions } from '@patternfly/react-table'
import { ToolbarSearch } from 'Common'
import { createReactWrapper } from 'utilities'

import type { Backend } from 'BackendApis/types'

import './IndexPage.scss'

type Props = {
  newBackendPath: string,
  backends: Array<Backend>,
  backendsCount: number
};

const IndexPage = (
  {
    newBackendPath,
    backendsCount,
    backends
  }: Props
): React.ReactElement => {
  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Private base URL',
    'Linked products'
  ]

  const tableRows = backends.map((tableRow) => ({
    cells: [
      { title: <Button href={tableRow.links[1].path} component="a" variant="link" isInline>{tableRow.name}</Button> },
      tableRow.systemName,
      <span className="api-table-timestamp">{tableRow.updatedAt}</span>,
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
    onClick: (_event, rowId) => linkToPage(rowId, i)
  }))

  const url = new URL(window.location.href)

  const selectPerPage: OnPerPageSelect = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', String(selectedPerPage))
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (page: any) => {
    url.searchParams.set('page', page)
    window.location.replace(url.toString())
  }

  const Pagination = ({
    variant
  }: {
    variant?: PaginationProps['variant']
  }) => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        widgetId="pagination-options-menu-top"
        itemCount={backendsCount}
        perPage={Number(perPage) || 20}
        page={Number(page)}
        onPerPageSelect={selectPerPage}
        onNextClick={(_ev, page) => goToPage(page)}
        onPreviousClick={(_ev, page) => goToPage(page)}
        onFirstClick={(_ev, page) => goToPage(page)}
        onLastClick={(_ev, page) => goToPage(page)}
        perPageOptions={[ { title: '10', value: 10 }, { title: '20', value: 20 } ]}
        variant={variant}
      />
    )
  }

  return (
    <PageSection variant={PageSectionVariants.light} id="backend-apis-index-page">
      <Level>
        <LevelItem>
          <Title headingLevel="h1" size="2xl">Backends</Title>
        </LevelItem>
        <LevelItem>
          <Button variant="primary" component="a" href={newBackendPath}>
            Create Backend
          </Button>
        </LevelItem>
      </Level>
      <p>Explore and manage all your internal APIs.</p>
      <Divider/>
      <Toolbar id="top-toolbar" className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <ToolbarSearch placeholder="Find a backend" />
        </ToolbarItem>
        {/* <ToolbarItem align={{ default: 'alignRight' }}> TODO: did align do anything? */}
        <ToolbarItem>
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Table aria-label="Backend APIs Table" actions={tableActions} cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar id="bottom-toolbar" className="pf-c-toolbar pf-u-justify-content-space-between">
        {/* <ToolbarItem align={{ default: 'alignRight' }}> TODO: did align do anything? */}
        <ToolbarItem>
          <Pagination variant={PaginationVariant.bottom} />
        </ToolbarItem>
      </Toolbar>
    </PageSection>
  )
}

const BackendsIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<IndexPage {...props} />, containerId)

export { IndexPage, BackendsIndexPageWrapper, Props }
